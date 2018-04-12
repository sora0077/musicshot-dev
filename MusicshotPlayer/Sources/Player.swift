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
    func playerCreatePlayerItem(_ item: PlayerItem)
    func playerDidEndPlayToEndTime(_ item: PlayerItem) throws
}

extension PlayerMiddleware {
    public func playerCreatePlayerItem(_ item: PlayerItem) {}
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
    private let maxProcessingCount = 3

    private var waitings: ArraySlice<PlayerItem> = []
    private var fetchings: ArraySlice<PlayerItem> = []
    private var queueings: ArraySlice<AVPlayerItem> = []

    var canProcess: Bool { return (fetchings.count + queueings.count) < maxProcessingCount }

    mutating func append(_ item: PlayerItem) {
        waitings.append(item)
    }

    mutating func popFirst() -> PlayerItem? {
        guard let item = waitings.popFirst() else { return nil }
        fetchings.append(item)
        return item
    }

    mutating func move(_ item: PlayerItem) -> AVPlayerItem? {
        if let index = fetchings.index(of: item) {
            fetchings.remove(at: index)
        }
        guard let url = item.url else { return nil }
        let playerItem = configureFading(of: AVPlayerItem(url: url))
        queueings.append(playerItem)
        return playerItem
    }

    mutating func remove(_ item: AVPlayerItem) {
        guard let index = queueings.index(of: item) else { return }
        queueings.remove(at: index)
    }
}

public final class Player {
    private let player = AVQueuePlayer()
    private let waitingQueue = FIFOQueue<PlayerItem>()
    private let disposeBag = MusicshotUtility.DisposeBag()
    public private(set) lazy var errors = self._errors.asObservable()
    private let _errors = PublishSubject<Error>()

    private var middlewares: [PlayerMiddleware] = []
    private var items = ItemController() {
        didSet {
            print(#function, "---------\n", items, "\n---------")
        }
    }

    public init() {
        #if targetEnvironment(simulator)
            player.volume = 0.02
            print("simulator")
        #else
            print("iphone")
        #endif

        player.rx.observe(\.currentItem, options: [.old, .new])
            .subscribe(onNext: { [weak self] _, item, change in
                if let old = change.oldValue ?? nil {
                    self?.items.remove(old)
                }
                self?.fetchIfNeeded()
            })
            .disposed(by: disposeBag)

        waitingQueue.asObservable()
            .map { try $0.value() }
            .do(onError: { [weak self] error in self?._errors.onNext(error) })
            .catchError { _ in .empty() }
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

    //
    // MARK: -
    public func install(middleware: PlayerMiddleware) {
        middlewares.append(middleware)
    }

    public func insert(_ item: PlayerItem) {
        items.append(item)
        fetchIfNeeded()
    }

    //
    // MARK: -
    private func fetchIfNeeded() {
        guard items.canProcess else { return }
        guard let item = items.popFirst() else { return }

        waitingQueue.append(item.fetcher
            .do(onSuccess: { url in
                item.url = url
            })
            .map { _ in item }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
        )
    }

    private func register(_ item: PlayerItem) {
        defer { fetchIfNeeded() }
        guard let playerItem = items.move(item) else { return }
        middlewares.reversed().forEach { middleware in
            middleware.playerCreatePlayerItem(item)
        }

        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime, object: playerItem)
            .compactMap { $0.object as? AVPlayerItem }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] playerItem in
                self?.middlewares.reversed().forEach { middleware in
                    do {
                        try middleware.playerDidEndPlayToEndTime(item)
                    } catch {
                        self?._errors.onNext(error)
                    }
                }
            })
            .disposed(by: disposeBag)

        player.insert(playerItem, after: nil)
        if player.status == .readyToPlay {
            player.play()
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
