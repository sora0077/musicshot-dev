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
}
