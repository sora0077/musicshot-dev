//
//  Repository+Preview.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/28.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

private let diskCache = DiskCacheImpl()

extension Repository {
    final class Preview {
        enum Error: Swift.Error {
            case unknownState
        }
        private let id: Entity.Song.Identifier

        convenience init(song: Entity.Song) {
            self.init(id: song.id)
        }

        init(id: Entity.Song.Identifier) {
            self.id = id
        }

        func fetch() -> Single<(URL, Int)> {
            enum State {
                case cache(URL, Int)
                case download(Int, URL, Entity.Song.Ref)
            }
            let id = self.id
            return Single<State>
                .just {
                    let realm = try Realm()
                    let song = realm.object(ofType: Entity.Song.self, forPrimaryKey: id)
                    switch (song, song?.preview) {
                    case (nil, _):
                        throw Error.unknownState
                    case (_?, let preview?):
                        if let url = preview.localURL, FileManager.default.fileExists(atPath: url.path) {
                            return .cache(url, preview.duration)
                        } else {
                            return .cache(preview.remoteURL, preview.duration)
                        }
                    case (let song?, nil):
                        guard let id = Int(id) else { throw Error.unknownState }
                        return .download(id, song.url, song.ref)
                    }
                }
                .flatMap { state -> Single<(URL, Int)> in
                    switch state {
                    case .cache(let args):
                        return .just(args)
                    case .download(let id, let url, let ref):
                        return NetworkSession.shared.rx.send(GetPreviewURL(id: id, url: url))
                            .do(onSuccess: { url, duration in
                                let realm = try Realm()
                                guard let song = realm.resolve(ref) else { return }
                                try realm.write {
                                    realm.add(Entity.Preview(song: song, url: url, duration: duration), update: true)
                                }
                            })
                    }
                }
        }

        func download() -> Single<Void> {
            enum State {
                case notReady, onlyRemote(URL), downloaded
            }
            let id = self.id
            let dir = diskCache.dir
            return Single<State>
                .just {
                    let realm = try Realm()
                    let preview = realm.object(ofType: Entity.Preview.self, forPrimaryKey: id)
                    if let url = preview?.localURL, FileManager.default.fileExists(atPath: url.path) {
                        return .downloaded
                    }
                    if let url = preview?.remoteURL {
                        return .onlyRemote(url)
                    }
                    return .notReady
                }
                .flatMap { state -> Single<Void> in
                    switch state {
                    case .notReady, .downloaded:
                        return .just(())
                    case .onlyRemote(let url):
                        return URLSession.shared.rx.download(with: url)
                            .map { src in
                                guard let src = src else { return }

                                let filename = url.lastPathComponent
                                let realm = try Realm()
                                guard let preview = realm.object(ofType: Entity.Preview.self, forPrimaryKey: id) else { return }
                                try realm.write {
                                    let to = dir.appendingPathComponent(filename)
                                    try? FileManager.default.removeItem(at: to)
                                    try FileManager.default.moveItem(at: src, to: to)
                                    preview.localURL = to
                                }
                            }
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
                    }
                }
        }
    }
}

// MARK: - private
private enum Cache {
    static let directory: URL = {
        let base = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let dir = URL(fileURLWithPath: base).appendingPathComponent("tracks", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        return dir
    }()
}

private final class DiskCacheImpl: NSObject, NSFilePresenter {
    private lazy var _diskSizeInBytes = BehaviorRelay<Int>(value: self.diskSizeInBytes)

    let dir: URL

    var presentedItemURL: URL? { return dir }
    let presentedItemOperationQueue = OperationQueue()

    init(dir: URL = Cache.directory) {
        self.dir = dir
        super.init()

        NSFileCoordinator.addFilePresenter(self)
    }

    func presentedSubitemDidChange(at url: URL) {
        _diskSizeInBytes.accept(diskSizeInBytes)
    }

    var diskSizeInBytes: Int {
        do {
            let paths = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey])
            let sizes = try paths.compactMap {
                try $0.resourceValues(forKeys: [.fileSizeKey]).fileSize
            }
            return sizes.reduce(0, +)
        } catch {
            print(error)
            return 0
        }
    }

    func removeAll() -> Single<Void> {
        let dir = self.dir
        return Single.just {
            try FileManager.default.removeItem(at: dir)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }.subscribeOn(SerialDispatchQueueScheduler(qos: .background))
    }
}

private extension Reactive where Base: URLSession {
    func download(with url: URL) -> Single<URL?> {
        return Single.create(subscribe: { event in
            let task = URLSession.shared.downloadTask(with: url, completionHandler: { (url, _, error) in
                if let error = error {
                    event(.error(error))
                } else {
                    event(.success(url))
                }
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
    }
}
