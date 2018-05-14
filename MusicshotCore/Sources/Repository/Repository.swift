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
public typealias ResultsChange<T> = RealmCollectionChange<Results<T>> where T: RealmCollectionValue
public typealias ResultsPattern<T> = (@escaping (ResultsChange<T>) -> Void) -> (Results<T>, NotificationToken) where T: RealmCollectionValue

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
    public let songs = Songs()

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
            Entity.Ranking.Genre.self,
            Entity.Ranking.Genre.ChartUrls.self,
            Entity.Ranking.Genre.RssUrls.self,
            Resource.Charts.Songs.self,
            Resource.Charts.Albums.self,
            Resource.Search.Hints.self,
            Resource.Search.Songs.self,
            Resource.Search.SongsFragment.self,
            Resource.Ranking.Genre.self,
            Resource.Ranking.Genres.self,
            Resource.Ranking.GenreSongs.self,
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

    public final class Songs {
        public func song(for id: Entity.Song.Identifier) throws -> Entity.Song? {
            let realm = try Realm()
            return realm.object(ofType: Entity.Song.self, forPrimaryKey: id)
        }
    }

    public final class Ranking {
        public let genres = Genres()

        public func genre(with id: Entity.Genre.Identifier) -> Genre {
            return Genre(id: id)
        }

        public final class Genres {
            public func list() throws -> Results<Resource.Ranking.Genre> {
                let realm = try Realm()
                if let genres = realm.object(of: Resource.Ranking.Genres.self, \.createDate, within: 30.minutes) {
                    return genres.items()
                }
                try realm.write {
                    realm.add(Resource.Ranking.Genres(), update: true)
                }
                return try list()
            }

            public func all(_ change: @escaping ResultsChange<Resource.Ranking.Genre>.Event) throws -> ResultsChange<Resource.Ranking.Genre>.CollectionAndToken {
                let items = try list()
                return (items, items.observe(change))
            }

            public func fetch() -> Single<Void> {
                return Single<ListRankingGenres>
                    .storefront { storefront in
                        ListRankingGenres(country: storefront.id.rawValue)
                    }
                    .flatMap(NetworkSession.shared.rx.send)
                    .do(onSuccess: { response in
                        let realm = try Realm()
                        let genres = realm.objects(Resource.Ranking.Genres.self).first
                        try realm.write {
                            realm.add(response, update: true)

                            genres?.removeAll()
                            func addToGenres(_ genre: Entity.Ranking.Genre) {
                                genres?.append(genre)
                                for subgenre in genre.subgenres {
                                    addToGenres(subgenre)
                                }
                            }
                            addToGenres(response)
                        }
                    })
                    .map { _ in }
            }
        }

        public final class Genre {
            public enum Error: Swift.Error {
                case genreNotFound(Entity.Genre.Identifier)
            }
            private let id: Entity.Genre.Identifier

            fileprivate init(id: Entity.Genre.Identifier) {
                self.id = id
            }

            func list() throws -> List<Entity.Song> {
                let realm = try Realm()
                if let genre = realm.object(of: Resource.Ranking.GenreSongs.self, for: id, \.createDate, within: 30.minutes) {
                    return genre.items
                }
                try realm.write {
                    realm.add(Resource.Ranking.GenreSongs(id: id), update: true)
                }
                return try list()
            }

            public func all(_ change: @escaping ListChange<Entity.Song>.Event) throws -> ListChange<Entity.Song>.CollectionAndToken {
                let items = try list()
                return (items, items.observe(change))
            }

            public func fetch() -> Single<Void> {
                typealias Pair = (ListRankingRss, ([Entity.Song.Identifier]) -> GetMultipleSongs)

                let id = self.id
                return Single<Pair>
                    .storefront { storefront in
                        let realm = try Realm()
                        guard let selected = realm.object(ofType: Resource.Ranking.Genre.self, forPrimaryKey: id) else {
                            throw Error.genreNotFound(id)
                        }
                        let storefrontId = storefront.id
                        return (
                            ListRankingRss(url: selected.genre.rssUrls.topSongs), { ids in GetMultipleSongs(storefront: storefrontId, ids: ids) }
                        )
                    }
                    .flatMap { (request, songs) in
                        NetworkSession.shared.rx.send(request)
                            .flatMap { ids in
                                MusicSession.shared.rx.send(songs(ids)).map { ($0, ids) }
                            }
                    }
                    .do(onSuccess: { response, ids in
                        let realm = try Realm()
                        let songs = realm.object(ofType: Resource.Ranking.GenreSongs.self, forPrimaryKey: id)
                        try realm.write {
                            let items = response.data
                                .compactMap { $0.attributes }
                                .reduce(into: [Entity.Song.Identifier: Entity.Song]()) { dict, data in
                                    dict[data.id] = data
                                }
                            realm.add(items.values, update: true)

                            songs?.items.removeAll()
                            songs?.items.append(objectsIn: ids.compactMap { items[$0] })
                        }
                    })
                    .map { _ in }
            }
        }
    }
}
