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

extension UIColor {
    convenience init(hex: Int) {
        fatalError()
    }
}

final class SongRepositoryImpl: SongRepository {
    func fetch(by ids: Song.Identifier...) -> Single<Void> {
        return Single.read { realm in
            let cached = realm.objects(Song.Storage.self)
                .filter("id IN %@", ids)
                .map(SongImpl.init(storage:))
                .ids()
            let required = Set(ids).subtracting(cached)

        }
    }
}

extension Single {
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
