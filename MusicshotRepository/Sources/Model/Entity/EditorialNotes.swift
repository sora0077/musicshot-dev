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

extension EditorialNotes {
    typealias Storage = EditorialNotesImpl.Storage
}

final class EditorialNotesImpl: EditorialNotes {
    @objc(EditorialNotesStorage)
    final class Storage: RealmSwift.Object {
        @objc dynamic var standard: String = ""
        @objc dynamic var short: String = ""
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

    override var standard: String { return storage.standard }
    override var short: String { return storage.short }
}
