//
//  SongRepository.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import MusicshotDomain
import MusicshotUtility

extension UIColor {
    convenience init(hex: Int) {
        fatalError()
    }
}

final class SongRepositoryImpl: SongRepository {
    func fetch(by ids: [Song.Identifier]) -> Single<Void> {
        return Single
            .storefront { realm, storefront -> GetMultipleSongs in
                let cached = realm.objects(Song.Storage.self)
                    .filter("id IN %@", ids)
                    .map(SongImpl.init(storage:))
                    .ids()
                let required = Set(ids).subtracting(cached)
                return GetMultipleSongs(storefront: storefront.id, ids: required.map { $0.rawValue })
            }
            .flatMap(MusicSession.rx.response(from:))
            .map { response in
                let realm = try Realm()
                try realm.write {
                    realm.add(response.data.compactMap { $0.attributes }, update: true)
                }
            }
    }
}

extension Storefront {
    public struct NotFound: Error {}
}

extension Single {
    static func storefront(_ closure: @escaping (Realm, Storefront.Storage) throws -> Element) -> Single<Element> {
        return Single.create(subscribe: { event in
            do {
                let realm = try Realm()
                let prefs = realm.object(ofType: Preference.self, forPrimaryKey: Preference.pkValue)
                guard let storefront = prefs?.storefront else {
                    throw Storefront.NotFound()
                }
//                event(.success(try closure((realm, storefront))))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
}
