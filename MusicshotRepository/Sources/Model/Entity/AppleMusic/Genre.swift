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

extension Genre: EntityConvertible {
    typealias Impl = GenreImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! GenreImpl)._storage }  // swiftlint:disable:this force_cast
}

final class GenreImpl: Genre, EntityImplConvertible {
    @objc(GenreStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var name: String = ""
        @objc private dynamic var createDate: Date = Date()
    }

    fileprivate let _storage: Storage

    init(storage: Storage) {
        self._storage = storage
        super.init(id: .init(rawValue: storage.id))
    }

    convenience init?(storage: Storage?) {
        guard let storage = storage else { return nil }
        self.init(storage: storage)
    }

    override var name: String { return _storage.name }
    override var isInvalidated: Bool { return _storage.isInvalidated }
}

extension GenreImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
