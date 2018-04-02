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

private let maxQueueingCount = 3

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
    open fileprivate(set) var playerItem: AVPlayerItem?
    open var userInfo: Any?
    fileprivate let url: Single<URL>

    public init(url: Single<URL>) {
        self.url = url
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        return lhs === rhs
    }
}

public final class Player {
    private let player = AVQueuePlayer()
    private let waitingQueue = FIFOQueue<PlayerItem>()
    private let disposeBag = MusicshotUtility.DisposeBag()
    private let queueingCount: Observable<Int>
    public private(set) lazy var errors = self._errors.asObservable()
    private let _errors = PublishSubject<Error>()

    private var middlewares: [PlayerMiddleware] = []

    public init() {
        let insertNotifier = PublishSubject<Void>()
        queueingCount = Observable.combineLatest(
                player.rx.observe(\.currentItem)
                    .map { $1 }
                    .startWith(nil)
                    .delay(0.1, scheduler: SerialDispatchQueueScheduler(qos: .default)),
                insertNotifier.asObservable()
                    .startWith(())
            )
            .map { [weak player] _ in player?.items().count ?? 0 }
            .distinctUntilChanged()
            .do(onNext: { print("queueing:", $0) })
            .share()

        #if targetEnvironment(simulator)
            player.volume = 0.02
            print("simulator")
        #else
            print("iphone")
        #endif

        waitingQueue.asObservable()
            .map { try $0.value() }
            .do(onError: { [weak self] error in self?._errors.onNext(error) })
            .catchError { _ in .empty() }
            .subscribe(onNext: { [weak self] item in
                self?.register(item, notifier: insertNotifier)
            })
            .disposed(by: disposeBag)

        player.rx.observe(\.status)
            .subscribe(onNext: { player, _ in
                switch player.status {
                case .readyToPlay:
                    player.play()
                case .failed, .unknown:
                    player.pause()
                }
            })
            .disposed(by: disposeBag)
    }

    private func register(_ item: PlayerItem, notifier: PublishSubject<Void>) {
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime, object: item.playerItem)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] _ in
                self?.middlewares.reversed().forEach { middleware in
                    do {
                        try middleware.playerDidEndPlayToEndTime(item)
                    } catch {
                        self?._errors.onNext(error)
                    }
                }
                notifier.onNext(())
            })
            .disposed(by: disposeBag)

        player.insert(item.playerItem!, after: nil)
        notifier.onNext(())
        if player.status == .readyToPlay {
            player.play()
        }
    }

    //
    // MARK: -
    public func insert(_ item: PlayerItem) {
        waitingQueue.append(queueingCount
            .map { [weak self] _ in { self?.player.items().count ?? 0 } }
            .startWith({ [weak self] in self?.player.items().count ?? 0 })
            .filter { $0() <= maxQueueingCount }
            .take(1)
            .asSingle()
            .flatMap { _ in item.url }
            .map(AVPlayerItem.init(url:))
            .map(configureFading)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { [weak self] playerItem in
                item.playerItem = playerItem
                self?.middlewares.reversed().forEach { middleware in
                    middleware.playerCreatePlayerItem(item)
                }
            })
            .map { _ in item }
        )
    }

    public func install(middleware: PlayerMiddleware) {
        middlewares.append(middleware)
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
