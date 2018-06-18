//
//  Storefront.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Storefront: EntityConvertible {
    typealias Impl = StorefrontImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! StorefrontImpl)._storage }  // swiftlint:disable:this force_cast
}

final class StorefrontImpl: Storefront, EntityImplConvertible {
    @objc(StorefrontStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var name: String = ""
        let supportedLanguageTags = List<String>()
        @objc dynamic var defaultLanguageTag: String = ""
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
    override var supportedLanguageTags: [String] { return Array(_storage.supportedLanguageTags) }
    override var defaultLanguageTag: String { return _storage.defaultLanguageTag }
}
