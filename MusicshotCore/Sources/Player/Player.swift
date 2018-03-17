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

public final class Player {
    private let engine = AVAudioEngine()
    private let inputA = AVAudioPlayerNode()
    private let inputB = AVAudioPlayerNode()

    public init() {
        let mixer = engine.mainMixerNode
        engine.attach(inputA)
        engine.connect(inputA, to: engine.mainMixerNode, format: nil)
    }

    public func start() throws {
        try engine.start()
    }

    public func insert(_ fileURL: URL) throws {
        let file = try AVAudioFile(forReading: fileURL)
        inputA.scheduleFile(file, at: nil, completionHandler: nil)
        inputA.play()
    }
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
