//
//  Song.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Song: EntityConvertible {
    typealias Impl = SongImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! SongImpl)._storage }  // swiftlint:disable:this force_cast
}

final class SongImpl: Song, EntityImplConvertible {
    @objc(SongStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var albumName: String = ""
        @objc dynamic var artistName: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
        @objc dynamic var composerName: String?
        @objc dynamic var contentRating: String?
        @objc dynamic var discNumber: Int = 0
        let durationInMillis = RealmOptional<Int>(nil)
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        let genreNames = List<String>()
        @objc dynamic var isrc: String = ""
        let movementCount = RealmOptional<Int>(nil)
        @objc dynamic var movementName: String?
        let movementNumber = RealmOptional<Int>(nil)
        @objc dynamic var name: String = ""
        @objc dynamic var playParams: PlayParametersImpl.Storage!
        let previews = List<PreviewImpl.Storage>()
        @objc dynamic var releaseDate: Date = .distantPast
        @objc dynamic var trackNumber: Int = 0
        @objc dynamic var url: String = ""
        @objc dynamic var workName: String?
        @objc private dynamic var createDate: Date = Date()
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

    override var albumName: String { return _storage.albumName }
    override var artistName: String { return _storage.artistName }
    override var artwork: Artwork { return ArtworkImpl(storage: _storage.artwork) }
    override var composerName: String? { return _storage.composerName }
    override var contentRating: String? { return _storage.contentRating }
    override var discNumber: Int { return _storage.discNumber }
    override var durationInMillis: Int? { return _storage.durationInMillis.value }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var genreNames: [String] { return Array(_storage.genreNames) }
    override var isrc: String { return _storage.isrc }
    override var movementCount: Int? { return _storage.movementCount.value }
    override var movementName: String? { return _storage.movementName }
    override var movementNumber: Int? { return _storage.movementNumber.value }
    override var name: String { return _storage.name }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: _storage.playParams) }
    override var previews: [Preview] { return _storage.previews.map(PreviewImpl.init(storage:)) }
    override var releaseDate: Date { return _storage.releaseDate }
    override var trackNumber: Int { return _storage.trackNumber }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var workName: String? { return _storage.workName }
    override var isInvalidated: Bool { return _storage.isInvalidated }
}

extension SongImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
