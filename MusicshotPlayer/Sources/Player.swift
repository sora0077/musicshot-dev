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
    func playerDidEndPlayToEndTime(_ item: AVPlayerItem)
}

extension PlayerMiddleware {
    public func playerCreatePlayerItem(_ item: AVPlayerItem, with userInfo: Any?) {}
    public func playerDidEndPlayToEndTime(_ item: AVPlayerItem) {}
}

public final class Player {
    private let player = AVQueuePlayer()
    private let waitingQueue = FIFOQueue<AVPlayerItem>()
    private let disposeBag = MusicshotUtility.DisposeBag()
    private var statusToken: NSKeyValueObservation?
    private var currentItemToken: NSKeyValueObservation?
    private let queueingCount: Observable<Int>

    private var middlewares: [PlayerMiddleware] = []

    public init() {
        queueingCount = player.rx.observe(\.currentItem)
            .map { $0.0.items().count }
            .debug()
            .do(onNext: { print("queueing:", $0) })

        #if (arch(i386) || arch(x86_64)) && os(iOS)
            player.volume = 0.02
            print("simulator")
        #else
            print("iphone")
        #endif

        let playerItems = waitingQueue.asObservable()
            .map { try $0.value() }
            .catchError { error in
                print(error)
                return .empty()
            }
            .share()

        playerItems
            .subscribe(onNext: { [weak self] item in
                print("play:", item)
                self?.player.insert(item, after: nil)
                if self?.player.status == .readyToPlay {
                    self?.player.play()
                }
            })
            .disposed(by: disposeBag)

        playerItems
            .flatMap { item in
                NotificationCenter.default.rx
                    .notification(.AVPlayerItemDidPlayToEndTime, object: item)
            }
            .compactMap { $0.object as? AVPlayerItem }
            .subscribe(onNext: { [weak self] item in
                self?.middlewares.reversed().forEach { middleware in
                    middleware.playerDidEndPlayToEndTime(item)
                }
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

    public func insert(_ url: Single<URL>, userInfo: Any? = nil) {
        waitingQueue.append(queueingCount
            .startWith(player.items().count)
            .filter { $0 <= 3 }
            .take(1)
            .asSingle()
            .flatMap { _ in url }
            .map(AVPlayerItem.init(url:))
            .map(configureFading)
            .do(onSuccess: { [weak self] item in
                self?.middlewares.reversed().forEach { middleware in
                    middleware.playerCreatePlayerItem(item, with: userInfo)
                }
            })
            .debug()
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
