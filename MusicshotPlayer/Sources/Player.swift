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
    func playerCreatePlayerItem(_ item: AVPlayerItem, with userInfo: Any?)
    func playerDidEndPlayToEndTime(_ item: AVPlayerItem) throws
}

extension PlayerMiddleware {
    public func playerCreatePlayerItem(_ item: AVPlayerItem, with userInfo: Any?) {}
    public func playerDidEndPlayToEndTime(_ item: AVPlayerItem) throws {}
}

private let maxQueueingCount = 3

public final class Player {
    open class Item {
        private let url: Single<URL>

        public init(url: Single<URL>) {
            self.url = url
        }
    }

    private let player = AVQueuePlayer()
    private let waitingQueue = FIFOQueue<AVPlayerItem>()
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
                    .delay(0.1, scheduler: SerialDispatchQueueScheduler(qos: .default))
                    .do(onNext: { [weak player] _ in print("hogehoge", player?.items().count ?? 0) }),
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
            .catchError { [weak self] error in
                self?._errors.onNext(error)
                return .empty()
            }
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

    private func register(_ item: AVPlayerItem, notifier: PublishSubject<Void>) {
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime, object: item)
            .compactMap { $0.object as? AVPlayerItem }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] item in
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

        player.insert(item, after: nil)
        notifier.onNext(())
        if player.status == .readyToPlay {
            player.play()
        }
    }

    //
    // MARK: -
    public func insert(_ url: Single<URL>, userInfo: Any? = nil) {
        waitingQueue.append(queueingCount
            .map { [weak self] _ in { self?.player.items().count ?? 0 } }
            .startWith({ [weak self] in self?.player.items().count ?? 0 })
            .filter { $0() <= maxQueueingCount }
            .take(1)
            .asSingle()
            .flatMap { _ in url }
            .map(AVPlayerItem.init(url:))
            .map(configureFading)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { [weak self] item in
                self?.middlewares.reversed().forEach { middleware in
                    middleware.playerCreatePlayerItem(item, with: userInfo)
                }
            })
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
