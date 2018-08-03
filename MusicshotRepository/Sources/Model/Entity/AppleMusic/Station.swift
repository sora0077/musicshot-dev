//
//  Station.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Station: EntityConvertible {
    typealias Impl = StationImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! StationImpl)._storage }  // swiftlint:disable:this force_cast
}

final class StationImpl: Station, EntityImplConvertible {
    @objc(StationStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
        let durationInMillis = RealmOptional<Int>(nil)
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        let episodeNumber = RealmOptional<Int>(nil)
        @objc dynamic var isLive: Bool = false
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
    override var durationInMillis: Int? { return _storage.durationInMillis.value }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var episodeNumber: Int? { return _storage.episodeNumber.value }
    override var isLive: Bool { return _storage.isLive }
    override var name: String { return _storage.name }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var isInvalidated: Bool { return _storage.isInvalidated }
}

extension StationImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
