//
//  Repository.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/07.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
@_exported import RealmSwift

final class StorefrontHolder: Object {
    let list = List<Entity.Storefront>()
}

final class SelectedStorefront: Object {
    @objc dynamic var storefront: Entity.Storefront?
}

public typealias ListChange<T> = RealmCollectionChange<List<T>> where T: RealmCollectionValue
public typealias ListPattern<T> = (@escaping (ListChange<T>) -> Void) -> (List<T>, NotificationToken) where T: RealmCollectionValue

func musicshotRealm() -> Realm {
    return try! Realm()
}

public class Repository {
    public let storefronts = Storefronts()

    init() {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config

        #if DEBUG
            if let path = config.fileURL?.absoluteString.components(separatedBy: "file://").last {
                print("open \(path)")
            }
        #endif
    }

    public final class Storefronts {
        public func selected() -> Entity.Storefront? {
            return musicshotRealm().objects(SelectedStorefront.self).first?.storefront
        }

        public func select(_ storefront: Entity.Storefront) {
            let realm = musicshotRealm()
            try! realm.write {
                realm.delete(realm.objects(SelectedStorefront.self))
                let selected = SelectedStorefront()
                selected.storefront = storefront
                realm.add(selected)
            }
        }

        public func all(_ change: @escaping (ListChange<Entity.Storefront>) -> Void) -> (List<Entity.Storefront>, NotificationToken) {
            let realm = musicshotRealm()
            if let holder = realm.objects(StorefrontHolder.self).first {
                return (holder.list, holder.list.observe(change))
            }
            let holder = StorefrontHolder()
            try! realm.write {
                realm.add(holder)
            }
            MusicSession.shared.send(GetAllStorefronts(language: "ja-JP")) { result in
                switch result {
                case .success(let response):
                    let realm = musicshotRealm()
                    let holder = realm.objects(StorefrontHolder.self).first
                    try! realm.write {
                        let storefronts = response.data.flatMap { $0.attributes }
                        realm.add(storefronts, update: true)
                        holder?.list.append(objectsIn: storefronts)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            return (holder.list, holder.list.observe(change))
        }
    }
}
