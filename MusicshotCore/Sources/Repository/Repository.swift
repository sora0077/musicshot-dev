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

public typealias ListChange<T> = RealmCollectionChange<List<T>> where T: RealmCollectionValue
public typealias ListPattern<T> = (@escaping (ListChange<T>) -> Void) -> (List<T>, NotificationToken) where T: RealmCollectionValue

public class Repository {
    public enum Error: Swift.Error {
        case storefrontNotReady
    }
    public let storefronts = Storefronts()
    public let charts = Charts()

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
            Resource.Charts.self,
            Resource.Charts.Songs.self,
            Resource.Charts.Albums.self,
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
        public func selected() -> Entity.Storefront? {
            return (try? Realm().objects(InternalResource.SelectedStorefront.self).first?.storefront) ?? nil
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

    public final class Charts {
//        public func all(_ change: @escaping (ListChange<Entity.Charts>) -> Void) throws -> (List<Entity.Storefront>, NotificationToken) {
//            let realm = try Realm()
//            if let holder = realm.objects(StorefrontHolder.self).first {
//                return (holder.list, holder.list.observe(change))
//            }
//            let holder = StorefrontHolder()
//            try realm.write {
//                realm.add(holder)
//            }
//            return (holder.list, holder.list.observe(change))
//        }

        public func fetch(chart: String? = nil) -> Single<Void> {
            return Single<GetCharts>
                .just {
                    guard let storefront = try Realm()
                        .objects(InternalResource.SelectedStorefront.self)
                        .first?.storefront else {
                            throw Error.storefrontNotReady
                    }
                    return GetCharts.init(storefront: storefront.id, types: [.songs], chart: chart)
                }
                .flatMap(MusicSession.shared.rx.send)
                .do(onSuccess: { response in
                    let realm = try Realm()
                    try realm.write {
                        realm.add(response.songs?.data.compactMap { $0.attributes } ?? [], update: true)
                        realm.add(response.albums?.data.compactMap { $0.attributes } ?? [], update: true)
                        realm.add(response.musicVideos?.data.compactMap { $0.attributes } ?? [], update: true)

                        if let songs = try Resource.Charts.Songs(response.songs, isDefault: chart == nil) {
                            realm.add(songs, update: true)
                        }
                    }
                })
                .map { _ in }
        }
    }
}
