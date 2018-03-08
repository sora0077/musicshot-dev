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

final class StorefrontHolder: Object {
    let list = List<Entity.Storefront>()
}

final class SelectedStorefront: Object {
    @objc dynamic var storefront: Entity.Storefront?
}

public typealias ListChange<T> = RealmCollectionChange<List<T>> where T: RealmCollectionValue
public typealias ListPattern<T> = (@escaping (ListChange<T>) -> Void) -> (List<T>, NotificationToken) where T: RealmCollectionValue

public class Repository {
    public let storefronts = Storefronts()
    public let charts = Charts()

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
            return (try? Realm().objects(SelectedStorefront.self).first?.storefront) ?? nil
        }

        public func select(_ storefront: Entity.Storefront) throws {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(SelectedStorefront.self))
                let selected = SelectedStorefront()
                selected.storefront = storefront
                realm.add(selected)
            }
        }

        public func all(_ change: @escaping (ListChange<Entity.Storefront>) -> Void) throws -> (List<Entity.Storefront>, NotificationToken) {
            let realm = try Realm()
            if let holder = realm.objects(StorefrontHolder.self).first {
                return (holder.list, holder.list.observe(change))
            }
            let holder = StorefrontHolder()
            try realm.write {
                realm.add(holder)
            }
            return (holder.list, holder.list.observe(change))
        }

        public func fetch() -> Single<Void> {
            return MusicSession.shared.rx.send(GetAllStorefronts(language: "ja-JP"))
                .do(onSuccess: { response in
                    let realm = try Realm()
                    let holder = realm.objects(StorefrontHolder.self).first
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

        public func fetch() -> Single<Void> {
            struct Error: Swift.Error {}
            guard let storefront = (try? Realm().objects(SelectedStorefront.self).first?.storefront) ?? nil else {
                return .error(Error())
            }
            return MusicSession.shared.rx.send(GetCharts(storefront: storefront.id, types: [.songs], language: "ja-JP"))
                .do(onSuccess: { response in
                    print(response)
                })
                .map { _ in }
        }
    }
}
