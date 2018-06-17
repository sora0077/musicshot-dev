//
//  AppleCurator.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension AppleCurator {
    typealias Storage = AppleCuratorImpl.Storage

    var storage: Storage { return (self as! AppleCuratorImpl)._storage }  // swiftlint:disable:this force_cast
}

final class AppleCuratorImpl: AppleCurator {
    @objc(AppleCuratorStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        @objc dynamic var name: String = ""
        @objc dynamic var url: String = ""
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

    override var artwork: Artwork { return ArtworkImpl(storage: _storage.artwork) }
    override var editorialNotes: EditorialNotes? { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var name: String { return _storage.name }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
}
