//
//  Repository.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/07.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
@_exported import RealmSwift
import RxSwift
import AppleMusicKit
import MusicshotUtility

public typealias ListChange<T> = RealmCollectionChange<List<T>> where T: RealmCollectionValue
public typealias ListPattern<T> = (@escaping (ListChange<T>) -> Void) -> (List<T>, NotificationToken) where T: RealmCollectionValue

extension RealmCollectionChange {
    public typealias Event = (RealmCollectionChange<CollectionType>) -> Void
    public typealias CollectionAndToken = (collection: CollectionType, token: NotificationToken)
}

extension ThreadConfined {
    typealias Ref = ThreadSafeReference<Self>

    var ref: Ref { return Ref(to: self) }
}

extension Single {
    static func storefront(_ body: (Entity.Storefront) throws -> E) -> Single<E> {
        return Single.just {
            guard let storefront = try Realm()
                .objects(InternalResource.SelectedStorefront.self)
                .first?.storefront else {
                    throw Repository.Error.storefrontNotReady
            }
            return try body(storefront)
        }
    }
}

public class Repository {
    public enum Error: Swift.Error {
        case storefrontNotReady
    }
    public enum CollectionChanges {
        case initial
        case update(deletions: [Int], insertions: [Int], modifications: [Int])

        init<T>(_ changes: RealmCollectionChange<T>) throws {
            switch changes {
            case .initial:
                self = .initial
            case .update(_, let deletions, let insertions, let modifications):
                self = .update(deletions: deletions, insertions: insertions, modifications: modifications)
            case .error(let error):
                throw error
            }
        }
    }
    public let storefronts = Storefronts()
    public let charts = Charts()
    public let search = Search()
    public let history = History()
    public let ranking = Ranking()

    init() {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        config.objectTypes = [
            Entity.Storefront.self,
            Entity.Song.self,
            Entity.MusicVideo.self,
            Entity.Album.self,
            Entity.Artist.self,
            Entity.Genre.self,
            Entity.Artwork.self,
            Entity.PlayParameters.self,
            Entity.EditorialNotes.self,
            Entity.Preview.self,
            Entity.History.self,
            Resource.Charts.Songs.self,
            Resource.Charts.Albums.self,
            Resource.Search.Songs.self,
            Resource.Search.SongsFragment.self,
            Resource.Ranking.Genre.self,
            Resource.Ranking.Genre.ChartUrls.self,
            Resource.Ranking.Genre.RssUrls.self,
            InternalResource.StorefrontHolder.self,
            InternalResource.SelectedStorefront.self,
            InternalResource.Media.self,
            InternalResource.Request.self,
            InternalResource.Histories.self
        ]
        Realm.Configuration.defaultConfiguration = config

        #if DEBUG
            if let path = config.fileURL?.absoluteString.components(separatedBy: "file://").last {
                print("open \(path)")
            }
        #endif
    }

    public final class Ranking {
        public let genres = Genres()

        public final class Genres {
            public func fetch() -> Single<Void> {
                return Single<ListRankingGenres>
                    .storefront { storefront in
                        ListRankingGenres(country: storefront.id)
                    }
                    .flatMap(NetworkSession.shared.rx.send)
                    .do(onSuccess: { response in
                        let realm = try Realm()
                        try realm.write {
                            realm.add(response)
                        }
                    })
                    .map { _ in }
            }
        }
    }

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
