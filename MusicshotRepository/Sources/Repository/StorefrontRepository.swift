//
//  StorefrontRepository.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/17.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import MusicshotDomain
import MusicshotUtility

extension Single {
    static func storefront(_ closure: @escaping (Realm, Storefront.Storage) throws -> Element) -> Single<Element> {
        return Single.deferred {
            let realm = try Realm()
            guard let storefront = Preference.from(realm)?.storefront else {
                throw Storefront.NotFound()
            }
            return try .just(closure(realm, storefront))
        }
    }

    static func read(_ closure: @escaping (Realm) throws -> Element) -> Single<Element> {
        return Single.deferred {
            return try .just(closure(Realm()))
        }
    }
}

public func registry() -> StorefrontRepository {
    do {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = configuration
    }
    return StorefrontRepositoryImpl()
}

public enum Infra {
}

extension Infra {
    public static var storefront: StorefrontRepository {
        return StorefrontRepositoryImpl()
    }
}

private final class StorefrontRepositoryImpl: StorefrontRepository {
    func currentStorefront() throws -> Storefront? {
        return StorefrontImpl(storage: Preference.from(try Realm())?.storefront)
    }

    func saveCurrentStorefront(_ storefront: Storefront?) throws {
        let realm = try Realm()
        try realm.write {
            let prefs = Preference.from(realm) ?? Preference()
            prefs.storefront = storefront?.storage
            realm.add(prefs, update: true)
        }
    }

    func allStorefronts() throws -> LiveCollection<Storefront> {
        return LiveCollection.from(try Realm().objects(Storefront.Storage.self))
    }

    func fetch(by ids: [Storefront.Identifier]) -> Single<Void> {
        return Single
            .read { realm -> GetMultipleStorefronts in
                let cached = realm.objects(Storefront.Storage.self)
                    .filter("id IN %@", ids)
                    .map(StorefrontImpl.init(storage:))
                    .ids
                let required = Set(ids) - cached
                return GetMultipleStorefronts(ids: required.rawValues)
            }
            .flatMap(MusicSession.rx.response)
            .map { response in
                let realm = try Realm()
                try realm.write {
                    realm.add(response.data.compactMap(\.attributes), update: true)
                }
            }
    }

    func fetchAll() -> Single<Void> {
        return MusicSession.rx.response(from: GetAllStorefronts())
            .map { response in
                let realm = try Realm()
                try realm.write {
                    realm.add(response.data.compactMap(\.attributes), update: true)
                }
            }
    }
}

extension Sequence {
    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        return compactMap { $0[keyPath: keyPath] }
    }
}
