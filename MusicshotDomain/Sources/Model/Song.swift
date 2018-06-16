//
//  Song.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Song: Entity {
    public typealias Identifier = Tagged<Song, String>

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier

    public init(id: Identifier) {
        self.id = id
    }

    /// The name of the album the song appears on.
    open var albumName: String { fatalError("abstract") }
    /// The artist’s name.
    open var artistName: String { fatalError("abstract") }
    /// The album artwork.
    open var artwork: Artwork { fatalError("abstract") }
    /// (Optional) The song’s composer.
    open var composerName: String? { fatalError("abstract") }
    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
    open var contentRating: String? { fatalError("abstract") }
    /// The disc number the song appears on.
    open var discNumber: Int { fatalError("abstract") }
    /// (Optional) The duration of the song in milliseconds.
    open var durationInMillis: Int? { fatalError("abstract") }
    /// (Optional) The notes about the song that appear in the iTunes Store.
    open var editorialNotes: EditorialNotes { fatalError("abstract") }
    /// The genre names the song is associated with.
    open var genreNames: [String] { fatalError("abstract") }
    /// The ISRC (International Standard Recording Code) for the song.
    open var isrc: String { fatalError("abstract") }
    /// (Optional, classical music only) The movement count of this song.
    open var movementCount: Int? { fatalError("abstract") }
    /// (Optional, classical music only) The movement name of this song.
    open var movementName: String? { fatalError("abstract") }
    /// (Optional, classical music only) The movement number of this song.
    open var movementNumber: Int? { fatalError("abstract") }
    /// The localized name of the song.
    open var name: String { fatalError("abstract") }
    /// (Optional) The parameters to use to playback the song.
    open var playParams: PlayParameters? { fatalError("abstract") }
    /// The preview assets for the song.
    open var previews: [Preview] { fatalError("abstract") }
    /// The release date of the music video in YYYY-MM-DD format.
    open var releaseDate: Date { fatalError("abstract") }
    /// The number of the song in the album’s track list.
    open var trackNumber: Int { fatalError("abstract") }
    /// The URL for sharing a song in the iTunes Store.
    open var url: URL { fatalError("abstract") }
    /// (Optional, classical music only) The name of the associated work.
    open var workName: String? { fatalError("abstract") }
}
