//
//  EditorialNotes.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension EditorialNotes: EntityConvertible {
    typealias Impl = EditorialNotesImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! EditorialNotesImpl)._storage }  // swiftlint:disable:this force_cast
}

final class EditorialNotesImpl: EditorialNotes, EntityImplConvertible {
    @objc(EditorialNotesStorage)
    final class Storage: RealmSwift.Object {
        @objc dynamic var standard: String = ""
        @objc dynamic var short: String = ""
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

    override var standard: String { return _storage.standard }
    override var short: String { return _storage.short }
}

extension EditorialNotesImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
