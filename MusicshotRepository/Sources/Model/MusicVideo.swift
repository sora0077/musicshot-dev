//
//  MusicVideo.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

final class MusicVideoImpl: MusicVideo {
    @objc(MusicVideoStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var albumName: String?
        @objc dynamic var artistName: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
        @objc dynamic var contentRating: String?
        let durationInMillis = RealmOptional<Int>(nil)
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        let genreNames = List<String>()
        @objc dynamic var isrc: String = ""
        @objc dynamic var name: String = ""
        @objc dynamic var playParams: PlayParametersImpl.Storage!
        let previews = List<PreviewImpl.Storage>()
        @objc dynamic var releaseDate: Date = .distantPast
        let trackNumber = RealmOptional<Int>(nil)
        @objc dynamic var url: String = ""
        @objc dynamic var videoSubType: String?
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
    override var durationInMillis: Int? { return storage.durationInMillis.value }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: storage.editorialNotes) }
    override var genreNames: [String] { return Array(storage.genreNames) }
    override var isrc: String { return storage.isrc }
    override var name: String { return storage.name }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: storage.playParams) }
    override var previews: [Preview] { return storage.previews.map(PreviewImpl.init(storage:)) }
    override var releaseDate: Date { return storage.releaseDate }
    override var trackNumber: Int? { return storage.trackNumber.value }
    override var url: URL { return { URL(string: $0) }(storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var videoSubType: String? { return storage.videoSubType }
}
