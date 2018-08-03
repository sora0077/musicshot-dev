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

extension MusicVideo: EntityConvertible {
    typealias Impl = MusicVideoImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! MusicVideoImpl)._storage }  // swiftlint:disable:this force_cast
}

final class MusicVideoImpl: MusicVideo, EntityImplConvertible {
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
    override var durationInMillis: Int? { return _storage.durationInMillis.value }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var genreNames: [String] { return Array(_storage.genreNames) }
    override var isrc: String { return _storage.isrc }
    override var name: String { return _storage.name }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: _storage.playParams) }
    override var previews: [Preview] { return _storage.previews.map(PreviewImpl.init(storage:)) }
    override var releaseDate: Date { return _storage.releaseDate }
    override var trackNumber: Int? { return _storage.trackNumber.value }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var videoSubType: String? { return _storage.videoSubType }
    override var isInvalidated: Bool { return _storage.isInvalidated }
}

extension MusicVideoImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
