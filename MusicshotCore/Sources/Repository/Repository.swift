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

public typealias ListChange<T> = RealmCollectionChange<List<T>> where T: RealmCollectionValue
public typealias ListPattern<T> = (@escaping (ListChange<T>) -> Void) -> (List<T>, NotificationToken) where T: RealmCollectionValue

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
    public let storefronts = Storefronts()
    public let charts = Charts()
    public let search = Search()

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
            Resource.Charts.self,
            Resource.Charts.Songs.self,
            Resource.Charts.Albums.self,
            Resource.Search.Songs.self,
            Resource.Search.SongsFragment.self,
            InternalResource.StorefrontHolder.self,
            InternalResource.SelectedStorefront.self,
            InternalResource.Media.self,
            InternalResource.Request.self
        ]
        Realm.Configuration.defaultConfiguration = config

        #if DEBUG
            if let path = config.fileURL?.absoluteString.components(separatedBy: "file://").last {
                print("open \(path)")
            }
        #endif
    }

    public final class Storefronts {
        public func selected() throws -> Entity.Storefront? {
            return try Realm().objects(InternalResource.SelectedStorefront.self).first?.storefront
        }

        public func select(_ storefront: Entity.Storefront) throws {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(InternalResource.SelectedStorefront.self))
                let selected = InternalResource.SelectedStorefront()
                selected.storefront = storefront
                realm.add(selected)
            }
        }

        public func all(_ change: @escaping (ListChange<Entity.Storefront>) -> Void) throws -> (List<Entity.Storefront>, NotificationToken) {
            let realm = try Realm()
            if let holder = realm.objects(InternalResource.StorefrontHolder.self).first {
                return (holder.list, holder.list.observe(change))
            }
            try realm.write {
                realm.add(InternalResource.StorefrontHolder())
            }
            return try all(change)
        }

        public func fetch() -> Single<Void> {
            return MusicSession.shared.rx.send(GetAllStorefronts(language: "ja-JP"))
                .do(onSuccess: { response in
                    let realm = try Realm()
                    let holder = realm.objects(InternalResource.StorefrontHolder.self).first
                    try realm.write {
                        let storefronts = response.data.flatMap { $0.attributes }
                        realm.add(storefronts, update: true)
                        holder?.list.append(objectsIn: storefronts)
                    }
                })
                .map { _ in }
        }
    }

    public final class Preview {
        enum Error: Swift.Error {
            case unknownState
        }
        private let id: Entity.Song.Identifier

        public convenience init(song: Entity.Song) {
            self.init(id: song.id)
        }

        init(id: Entity.Song.Identifier) {
            self.id = id
        }

        public func fetch() -> Single<(URL, Int)> {
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
                    case .download(let iid, let url, let ref):
                        return NetworkSession.shared.rx.send(GetPreviewURL(id: iid, url: url))
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
