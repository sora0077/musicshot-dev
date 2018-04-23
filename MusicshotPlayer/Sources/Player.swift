//
//  Player.swift
//  MusicshotPlayer
//
//  Created by 林達也 on 2018/03/21.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
@_exported import AVFoundation
import RxSwift
import RxCocoa
import MusicshotUtility

public protocol PlayerMiddleware {
    func playerDidCreateItem(_ item: PlayerItem) throws
    func playerDidChangeCurrentItem(_ item: PlayerItem?) throws
    func playerDidEndPlayToEndTime(_ item: PlayerItem) throws
}

extension PlayerMiddleware {
    public func playerDidCreateItem(_ item: PlayerItem) throws {}
    public func playerDidChangeCurrentItem(_ item: PlayerItem?) throws {}
    public func playerDidEndPlayToEndTime(_ item: PlayerItem) throws {}
}

private extension AVPlayerItem {
    private struct Keys {
        static var item: UInt8 = 0
    }
    private final class Box<T: AnyObject> {
        weak var value: T?
        init(_ value: T) {
            self.value = value
        }
    }
    weak var item: PlayerItem? {
        get { return (objc_getAssociatedObject(self, &Keys.item) as? Box<PlayerItem>)?.value }
        set { objc_setAssociatedObject(self, &Keys.item, newValue.map(Box.init), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

open class PlayerItem: Equatable {
    open var userInfo: Any?
    fileprivate var url: URL?
    fileprivate let fetcher: Single<URL>

    public init(fetcher: Single<URL>) {
        self.fetcher = fetcher
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        return lhs === rhs
    }
}

private struct ItemController: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
        waitings: \(waitings.count),
        fetchings: \(fetchings.count),
        queueings: \(queueings.count)
        """
    }
    private let maxFetchingCount = 3
    private let maxQueueingCount = 10

    private var waitings: ArraySlice<PlayerItem> = []
    private var fetchings: ArraySlice<PlayerItem> = []
    private var queueings: ArraySlice<AVPlayerItem> = []
//    private var endings: ArraySlice<AVPlayerItem> = []

    var canProcess: Bool {
        return fetchings.count < maxFetchingCount
            && queueings.count < maxQueueingCount
    }

    mutating func append(_ item: PlayerItem) {
        waitings.append(item)
    }

    mutating func popFirst() -> PlayerItem? {
        guard let item = waitings.popFirst() else { return nil }
        fetchings.append(item)
        return item
    }

    mutating func move(_ item: PlayerItem) -> AVPlayerItem? {
        remove(item)
        guard let url = item.url else { return nil }
        let playerItem = configureFading(of: AVPlayerItem(url: url))
        queueings.append(playerItem)
        return playerItem
    }

    mutating func remove(_ item: PlayerItem) {
        if let index = fetchings.index(of: item) {
            fetchings.remove(at: index)
        }
    }

    mutating func remove(_ item: AVPlayerItem) {
        guard let index = queueings.index(of: item) else { return }
        queueings.remove(at: index)
    }
}

//
// MARK: -
public final class Player {
    public var isPlaying: Bool { return player.rate != 0 }

    private let player = AVQueuePlayer()
    private let waitingQueue = FIFOQueue<PlayerItem>()
    private let disposeBag = MusicshotUtility.DisposeBag()

    public private(set) lazy var errors = self._errors.asObservable()
    private let _errors = PublishSubject<Error>()

    private var timeObserver: Any?
    public private(set) lazy var currentTimer = self._currentTimer.asObservable()
    private let _currentTimer = PublishSubject<Double>()

    private var middlewares: [PlayerMiddleware] = []
    private var items = ItemController() {
        didSet {
            print(#function, "---------\n", items, "\n---------")
        }
    }
    private let queue = DispatchQueue(label: "player.queue")

    public init() {
        #if targetEnvironment(simulator)
            player.volume = 0.1
            print("simulator")
        #else
            print("iphone")
        #endif

        let interval = CMTime(seconds: 0.5, preferredTimescale: 2)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .global()) { [weak self] time in
            self?._currentTimer.onNext(time.seconds)
        }

        player.rx.observe(\.currentItem, options: [.old, .new])
            .subscribe(onNext: { [weak self] player, item, change in
                if let old = change.oldValue ?? nil {
                    self?.items.remove(old)
                }
                let currentItem = player.currentItem?.item
                self?.middlewares.reversed().forEach { middleware in
                    do {
                        try middleware.playerDidChangeCurrentItem(currentItem)
                    } catch {
                        self?._errors.onNext(error)
                    }
                }
                self?.fetchIfNeeded()
            })
            .disposed(by: disposeBag)

        waitingQueue.asObservable()
            .flatMap { [weak self] result -> Observable<PlayerItem> in
                do {
                    return .just(try result.value())
                } catch {
                    self?._errors.onNext(error)
                    return .empty()
                }
            }
            .subscribe(onNext: { [weak self] item in
                self?.register(item)
            })
            .disposed(by: disposeBag)

        player.rx.observe(\.status)
            .subscribe(onNext: { player, _, _ in
                switch player.status {
                case .readyToPlay:
                    player.play()
                case .failed, .unknown:
                    player.pause()
                }
            })
            .disposed(by: disposeBag)
    }

    deinit {
        timeObserver.map(player.removeTimeObserver)
    }

    //
    // MARK: -
    public func install(middleware: PlayerMiddleware) {
        middlewares.append(middleware)
    }

    public func insert(_ item: PlayerItem) {
        queue.async {
            self.items.append(item)
            self.fetchIfNeeded()
        }
    }

    public func play() {
        player.play()
    }

    public func pause() {
        player.pause()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    @discardableResult
    public func nextTrack() -> Bool {
        let noNext = player.currentItem == player.items().last
        player.advanceToNextItem()
        return noNext
    }

    //
    // MARK: -
    private func fetchIfNeeded() {
        queue.async {
            guard self.items.canProcess else { return }
            guard let item = self.items.popFirst() else { return }

            self.waitingQueue.append(item.fetcher
                .do(
                    onSuccess: { url in
                        item.url = url
                    },
                    onError: { [weak self] _ in
                        self?.items.remove(item)
                        self?.fetchIfNeeded()
                    }
                )
                .map { _ in item }
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            )
        }
    }

    private func register(_ item: PlayerItem) {
        queue.async {
            defer { self.fetchIfNeeded() }
            guard let playerItem = self.items.move(item) else { return }
            playerItem.item = item
            self.middlewares.reversed().forEach { middleware in
                do {
                    try middleware.playerDidCreateItem(item)
                } catch {
                    self._errors.onNext(error)
                }
            }

            NotificationCenter.default.rx
                .notification(.AVPlayerItemDidPlayToEndTime, object: playerItem)
                .compactMap { $0.object as? AVPlayerItem }
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [weak self] _ in
                    self?.middlewares.reversed().forEach { middleware in
                        do {
                            try middleware.playerDidEndPlayToEndTime(item)
                        } catch {
                            self?._errors.onNext(error)
                        }
                    }
                })
                .disposed(by: self.disposeBag)

            self.player.insert(playerItem, after: nil)
            if self.player.status == .readyToPlay {
                self.player.play()
            }
        }
    }
}

private func configureFading(of item: AVPlayerItem) -> AVPlayerItem {
    guard let track = item.asset.tracks(withMediaType: .audio).first else { return item }

    let inputParams = AVMutableAudioMixInputParameters(track: track)

    let fadeDuration = CMTime(seconds: 5, preferredTimescale: 600)
    let fadeOutStartTime = item.asset.duration - fadeDuration
    let fadeInStartTime = kCMTimeZero

    inputParams.setVolumeRamp(fromStartVolume: 0, toEndVolume: 1,
                              timeRange: CMTimeRange(start: fadeInStartTime, duration: fadeDuration))
    inputParams.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0,
                              timeRange: CMTimeRange(start: fadeOutStartTime, duration: fadeDuration))

    //    var callbacks = AudioProcessingTapCallbacks()
    //    var tap: Unmanaged<MTAudioProcessingTap>?
    //    MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)
    //    inputParams.audioTapProcessor = tap?.takeUnretainedValue()
    //    tap?.release()

    let audioMix = AVMutableAudioMix()
    audioMix.inputParameters = [inputParams]
    item.audioMix = audioMix
    return item
}
