//
//  Genre.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

final class GenreImpl: Genre {
    @objc(GenreStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "name" }

        @objc dynamic var name: String = ""
    }

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
        super.init()
    }

    convenience init?(storage: Storage?) {
        guard let storage = storage else { return nil }
        self.init(storage: storage)
    }

    override var name: String { return storage.name }
}
