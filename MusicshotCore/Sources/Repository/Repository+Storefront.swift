//
//  Repository+Storefront.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/22.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

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

    public func all(_ change: @escaping ListChange<Entity.Storefront>.Event) throws -> ListChange<Entity.Storefront>.CollectionAndToken {
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
