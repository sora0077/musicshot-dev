//
//  Player.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

public final class Player {
    private let player = AVQueuePlayer()
    private let waitingQueue = FIFOQueue<URL>()
    private let disposeBag = DisposeBag()
    private var statusToken: NSKeyValueObservation?
    private var currentItemToken: NSKeyValueObservation?
    private let queueingCount: Observable<Int>

    public init() {
        queueingCount = player.rx.observe(\.currentItem)
            .map { $0.0.items().count }
            .debug()
            .do(onNext: { print("queueing:", $0) })
            .share()

        #if (arch(i386) || arch(x86_64)) && os(iOS)
            player.volume = 0.02
            print("simulator")
        #else
            print("iphone")
        #endif

        waitingQueue.asObservable()
            .map { AVPlayerItem(url: try $0.value()) }
            .catchError { error in
                print(error)
                return .empty()
            }
            .subscribe(onNext: { [weak self] item in
                print("play:", item)
                if self?.player.status == .readyToPlay {
                    self?.player.play()
                }
                self?.player.insert(configureFading(of: item), after: nil)
            })
            .disposed(by: disposeBag)

        player.observe(\.status) { (player, _) in
            switch player.status {
            case .readyToPlay:
                player.play()
            case .failed, .unknown:
                player.pause()
            }
        }.disposed(by: disposeBag)
    }

    public func insert(_ url: Single<URL>) {
        waitingQueue.append(queueingCount
            .startWith(player.items().count)
            .filter { $0 <= 3 }
            .take(1)
            .asSingle()
            .flatMap { _ in url }
            .debug()
        )
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

private let cacheDirectoryURL: URL = {
    let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    return URL(fileURLWithPath: cache + "/tracks")
}()

public final class Downloader {
    public enum Error: Swift.Error {
        case unknown(URLResponse?)
    }
    private let session: URLSession

    public init() {
        session = URLSession(configuration: .default)
    }

    public func download(_ request: URLRequest) -> Single<URL> {
        let src = request.url!
        let dst = cacheDirectoryURL.appendingPathComponent(src.lastPathComponent)
        if FileManager.default.fileExists(atPath: dst.path) {
            return .just(dst)
        }
        return Single<URL>
            .create(subscribe: { [weak self] event in
                let task = self?.session.downloadTask(with: request) { (url, response, error) in
                    if let url = url {
                        event(.success(url))
                    } else {
                        event(.error(error ?? Error.unknown(response)))
                    }
                }
                task?.resume()
                return Disposables.create {
                    task?.cancel()
                }
            })
            .map { url -> URL in
                try FileManager.default.moveItem(at: url, to: dst)
                return dst
            }
    }
}
