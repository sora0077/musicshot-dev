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

extension Album {
    typealias Storage = AlbumImpl.Storage
}

final class AlbumImpl: Album {
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

    override var albumName: String? { return storage.albumName }
    override var artistName: String { return storage.artistName }
    override var artwork: Artwork { return ArtworkImpl(storage: storage.artwork) }
    override var contentRating: String? { return storage.contentRating }
    override var copyright: String? { return storage.copyright }
    override var editorialNotes: EditorialNotes? { return EditorialNotesImpl(storage: storage.editorialNotes) }
    override var genreNames: [String] { return Array(storage.genreNames) }
    override var isComplete: Bool { return storage.isComplete }
    override var isSingle: Bool { return storage.isSingle }
    override var name: String { return storage.name }
    override var recordLabel: String { return storage.recordLabel }
    override var releaseDate: Date { return storage.releaseDate }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: storage.playParams) }
    override var trackCount: Int { return storage.trackCount }
    override var url: URL { return { URL(string: $0) }(storage.url)! }  // swiftlint:disable:this force_unwrapping
}
