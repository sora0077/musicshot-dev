//
//  Artwork.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Artwork: EntityConvertible {
    typealias Impl = ArtworkImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! ArtworkImpl)._storage }  // swiftlint:disable:this force_cast
}

final class ArtworkImpl: Artwork, EntityImplConvertible {
    @objc(ArtworkStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "url" }

        @objc dynamic var width: Int = -1
        @objc dynamic var height: Int = -1
        @objc dynamic var url: String = ""
        let bgColor = RealmOptional<Int>(nil)
        let textColor1 = RealmOptional<Int>(nil)
        let textColor2 = RealmOptional<Int>(nil)
        let textColor3 = RealmOptional<Int>(nil)
        let textColor4 = RealmOptional<Int>(nil)
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

    override var width: Int { return _storage.width }
    override var height: Int { return _storage.height }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var bgColor: UIColor? { return _storage.bgColor.value.flatMap { UIColor(hex: $0) } }
    override var textColor1: UIColor? { return _storage.textColor1.value.flatMap { UIColor(hex: $0) } }
    override var textColor2: UIColor? { return _storage.textColor2.value.flatMap { UIColor(hex: $0) } }
    override var textColor3: UIColor? { return _storage.textColor3.value.flatMap { UIColor(hex: $0) } }
    override var textColor4: UIColor? { return _storage.textColor4.value.flatMap { UIColor(hex: $0) } }
}
