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
            Resource.Search.Songs.self,
            Resource.Search.SongsFragment.self,
            Resource.Ranking.SelectedGenre.self,
            Resource.Ranking.Genres.self,
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

        public final class Genres {
            public func all(_ change: @escaping ResultsChange<Resource.Ranking.SelectedGenre>.Event) throws -> ResultsChange<Resource.Ranking.SelectedGenre>.CollectionAndToken {
                let realm = try Realm()
                if let genres = realm.object(of: Resource.Ranking.Genres.self, \.createDate, within: 30.minutes) {
                    let items = genres.items()
                    return (items, items.observe(change))
                }
                try realm.write {
                    realm.add(Resource.Ranking.Genres(), update: true)
                }
                return try all(change)
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
    }
}
