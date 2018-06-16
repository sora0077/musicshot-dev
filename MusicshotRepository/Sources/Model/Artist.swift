//
//  Artist.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

final class ArtistImpl: Artist {
    @objc(ArtistStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        let genreNames = List<String>()
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        @objc dynamic var name: String = ""
        @objc dynamic var url: String = ""
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

    override var genreNames: [String] { return Array(storage.genreNames) }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: storage.editorialNotes) }
    override var name: String { return storage.name }
    override var url: URL { return { URL(string: $0) }(storage.url)! }  // swiftlint:disable:this force_unwrapping
}
