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
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let (red, green, blue) = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Infra {
    public static var song: SongRepository {
        return SongRepositoryImpl()
    }
}

private final class SongRepositoryImpl: SongRepository {
    func fetch(by ids: [Song.Identifier]) -> Single<Void> {
        return Single
            .storefront { realm, storefront -> GetMultipleSongs in
                let cached = realm.objects(Song.Storage.self)
                    .filter("id IN %@", ids)
                    .map(SongImpl.init(storage:))
                    .ids
                let required = Set(ids) - cached
                return GetMultipleSongs(storefront: storefront.id, ids: required.rawValues)
            }
            .flatMap(MusicSession.rx.response)
            .map { response in
                let realm = try Realm()
                try realm.write {
                    realm.add(response.data.compactMap(\.attributes), update: true)
                }
            }
    }
}
