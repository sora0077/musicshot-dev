//
//  Album.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Album: Entity {
    public typealias Identifier = Tagged<Album, String>

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier

    public init(id: Identifier) {
        self.id = id
    }

    /// (Optional) The name of the album the music video appears on.
    open var albumName: String? { fatalError("abstract") }
    /// The artist’s name.
    open var artistName: String { fatalError("abstract") }
    /// The album artwork.
    open var artwork: Artwork { fatalError("abstract") }
    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
    open var contentRating: String? { fatalError("abstract") }
    /// (Optional) The copyright text.
    open var copyright: String? { fatalError("abstract") }
    /// (Optional) The notes about the album that appear in the iTunes Store.
    open var editorialNotes: EditorialNotes? { fatalError("abstract") }
    /// The names of the genres associated with this album.
    open var genreNames: [String] { fatalError("abstract") }
    /// Indicates whether the album is complete. If true, the album is complete; otherwise, it is not. An album is complete if it contains all its tracks and songs.
    open var isComplete: Bool { fatalError("abstract") }
    /// Indicates whether the album contains a single song.
    open var isSingle: Bool { fatalError("abstract") }
    /// The localized name of the album.
    open var name: String { fatalError("abstract") }
    /// The name of the record label for the album.
    open var recordLabel: String { fatalError("abstract") }
    /// The release date of the album in YYYY-MM-DD format.
    open var releaseDate: Date { fatalError("abstract") }
    /// (Optional) The parameters to use to playback the tracks of the album.
    open var playParams: PlayParameters? { fatalError("abstract") }
    /// The number of tracks.
    open var trackCount: Int { fatalError("abstract") }
    /// The URL for sharing an album in the iTunes Store.
    open var url: URL { fatalError("abstract") }
}
