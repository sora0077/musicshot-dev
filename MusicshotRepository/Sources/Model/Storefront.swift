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

extension Storefront {
    typealias Storage = StorefrontImpl.Storage
}

final class StorefrontImpl: Storefront {
    @objc(StorefrontStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var name: String = ""
        let supportedLanguageTags = List<String>()
        @objc dynamic var defaultLanguageTag: String = ""
    }

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
        super.init(id: .init(rawValue: storage.id))
    }

    convenience init?(storage: Storage?) {
        guard let storage = storage else { return nil }
        self.init(storage: storage)
    }

    override var name: String { return storage.name }
    override var supportedLanguageTags: [String] { return Array(storage.supportedLanguageTags) }
    override var defaultLanguageTag: String { return storage.defaultLanguageTag }
}
