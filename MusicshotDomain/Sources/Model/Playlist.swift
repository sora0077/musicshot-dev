//
//  Playlist.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Playlist: Entity {
    public typealias Identifier = Tagged<Playlist, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// (Optional) The playlist artwork.
    open var artwork: Artwork? { fatalError("abstract") }
    /// (Optional) The display name of the curator.
    open var curatorName: String? { fatalError("abstract") }
    /// (Optional) A description of the playlist.
    open var editorialNotes: EditorialNotes { fatalError("abstract") }
    /// The date the playlist was last modified.
    open var lastModifiedDate: Date { fatalError("abstract") }
    /// The localized name of the album.
    open var name: String { fatalError("abstract") }
    /// The type of playlist.
    open var playlistType: String { fatalError("abstract") }
    /// (Optional) The parameters to use to playback the tracks in the playlist.
    open var playParams: PlayParameters? { fatalError("abstract") }
    /// The URL for sharing an album in the iTunes Store.
    open var url: URL { fatalError("abstract") }
}
