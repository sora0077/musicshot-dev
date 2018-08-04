//
//  Playlist.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Playlist: EntityConvertible {
    typealias Impl = PlaylistImpl
    typealias Storage = Impl.Storage

    var storage: Storage { return (self as! PlaylistImpl)._storage }  // swiftlint:disable:this force_cast
}

final class PlaylistImpl: Playlist, EntityImplConvertible {
    @objc(PlaylistStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "id" }

        @objc dynamic var id: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
        @objc dynamic var curatorName: String?
        @objc dynamic var editorialNotes: EditorialNotesImpl.Storage!
        @objc dynamic var lastModifiedDate: Date = .distantPast
        @objc dynamic var name: String = ""
        @objc dynamic var playlistType: String = ""
        @objc dynamic var playParams: PlayParametersImpl.Storage!
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

    override var artwork: Artwork? { return ArtworkImpl(storage: _storage.artwork) }
    override var curatorName: String? { return _storage.curatorName }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: _storage.editorialNotes) }
    override var lastModifiedDate: Date { return _storage.lastModifiedDate }
    override var name: String { return _storage.name }
    override var playlistType: String { return _storage.playlistType }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: _storage.playParams) }
    override var url: URL { return { URL(string: $0) }(_storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var isInvalidated: Bool { return _storage.isInvalidated }
}

extension PlaylistImpl: CustomStringConvertible {

    var description: String { return _storage.description }
}
