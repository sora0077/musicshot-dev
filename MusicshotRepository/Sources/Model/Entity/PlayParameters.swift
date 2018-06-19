//
//  PlayParameters.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension PlayParameters: EntityConvertible {
    typealias Impl = PlayParametersImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! PlayParametersImpl)._storage }  // swiftlint:disable:this force_cast
}

final class PlayParametersImpl: PlayParameters, EntityImplConvertible {
    @objc(PlayParametersStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var kind: String = ""
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

    override var kind: String { return _storage.kind }
}

extension PlayParametersImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
