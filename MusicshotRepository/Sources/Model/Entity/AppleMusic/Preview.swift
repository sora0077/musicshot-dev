//
//  Preview.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Preview: EntityConvertible {
    typealias Impl = PreviewImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! PreviewImpl)._storage }  // swiftlint:disable:this force_cast
}

final class PreviewImpl: Preview, EntityImplConvertible {
    @objc(PreviewStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "url" }

        @objc dynamic var url: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
    }

    fileprivate let _storage: Storage

    init(storage: Storage) {
        self._storage = storage
        super.init()
    }

    convenience init?(storage: Storage?) {
        guard let storage = storage else { return nil }
        self.init(storage: storage)
    }

    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var artwork: Artwork? { return ArtworkImpl(storage: _storage.artwork) }
}

extension PreviewImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
