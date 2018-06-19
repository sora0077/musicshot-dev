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

extension Artist: EntityConvertible {
    typealias Impl = ArtistImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! ArtistImpl)._storage }  // swiftlint:disable:this force_cast
}

final class ArtistImpl: Artist, EntityImplConvertible {
    @objc(ArtistStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        let genreNames = List<String>()
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

    override var genreNames: [String] { return Array(_storage.genreNames) }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var name: String { return _storage.name }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
}

extension ArtistImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
