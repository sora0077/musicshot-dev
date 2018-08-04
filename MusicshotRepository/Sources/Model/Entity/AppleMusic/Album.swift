//
//  Album.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Album: EntityConvertible {
    typealias Impl = AlbumImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! AlbumImpl)._storage }  // swiftlint:disable:this force_cast
}

final class AlbumImpl: Album, EntityImplConvertible {
    @objc(AlbumStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var albumName: String?
        @objc dynamic var artistName: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
        @objc dynamic var contentRating: String?
        @objc dynamic var copyright: String?
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        let genreNames = List<String>()
        @objc dynamic var isComplete: Bool = false
        @objc dynamic var isSingle: Bool = false
        @objc dynamic var name: String = ""
        @objc dynamic var recordLabel: String = ""
        @objc dynamic var releaseDate: Date = .distantPast
        @objc dynamic var playParams: PlayParametersImpl.Storage!
        @objc dynamic var trackCount: Int = 0
        @objc dynamic var url: String = ""
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

    override var albumName: String? { return _storage.albumName }
    override var artistName: String { return _storage.artistName }
    override var artwork: Artwork { return ArtworkImpl(storage: _storage.artwork) }
    override var contentRating: String? { return _storage.contentRating }
    override var copyright: String? { return _storage.copyright }
    override var editorialNotes: EditorialNotes? { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var genreNames: [String] { return Array(_storage.genreNames) }
    override var isComplete: Bool { return _storage.isComplete }
    override var isSingle: Bool { return _storage.isSingle }
    override var name: String { return _storage.name }
    override var recordLabel: String { return _storage.recordLabel }
    override var releaseDate: Date { return _storage.releaseDate }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: _storage.playParams) }
    override var trackCount: Int { return _storage.trackCount }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var isInvalidated: Bool { return _storage.isInvalidated }
}

extension AlbumImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
