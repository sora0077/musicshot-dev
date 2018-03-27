//
//  Repository+Preview.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/28.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

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
                        return .cache(preview.url, preview.duration)
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
    }
}
