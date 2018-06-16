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

final class PlaylistImpl: Playlist {
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

    override var artwork: Artwork? { return ArtworkImpl(storage: storage.artwork) }
    override var curatorName: String? { return storage.curatorName }
    override var editorialNotes: EditorialNotes { return EditorialNotesImpl(storage: storage.editorialNotes) }
    override var lastModifiedDate: Date { return storage.lastModifiedDate }
    override var name: String { return storage.name }
    override var playlistType: String { return storage.playlistType }
    override var playParams: PlayParameters? { return PlayParametersImpl(storage: storage.playParams) }
    override var url: URL { return { URL(string: $0) }(storage.url)! }  // swiftlint:disable:this force_unwrapping
}
