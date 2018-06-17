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

extension Storefront {
    public struct NotFound: Error {}
}

extension Single {
    static func storefront(_ closure: @escaping (Realm, Storefront.Storage) throws -> Element) -> Single<Element> {
        return Single.create(subscribe: { event in
            do {
                let realm = try Realm()
                guard let storefront = Preference.from(realm)?.storefront else {
                    throw Storefront.NotFound()
                }
                event(.success(try closure(realm, storefront)))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }

    static func read(_ closure: @escaping (Realm) throws -> Element) -> Single<Element> {
        return Single.create(subscribe: { event in
            do {
                event(.success(try closure(Realm())))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }

}

final class StorefrontRepositoryImpl: StorefrontRepository {
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

    func fetch(by ids: [Storefront.Identifier]) -> Single<Void> {
        return Single
            .read { realm -> GetMultipleStorefronts in
                let cached = realm.objects(Storefront.Storage.self)
                    .filter("id IN %@", ids)
                    .map(StorefrontImpl.init(storage:))
                    .ids()
                let required = Set(ids).subtracting(cached)
                return GetMultipleStorefronts.init(ids: required.rawValues())
            }
            .flatMap(MusicSession.rx.response)
            .map { response in
                let realm = try Realm()
                try realm.write {
                    realm.add(response.data.compactMap { $0.attributes }, update: true)
                }
            }
    }

    func fetchAll() -> Single<Void> {
        return MusicSession.rx.response(from: GetAllStorefronts(language: "ja-JP"))
            .map { response in
                let realm = try Realm()
                try realm.write {
                    realm.add(response.data.compactMap { $0.attributes }, update: true)
                }
            }
    }
}
