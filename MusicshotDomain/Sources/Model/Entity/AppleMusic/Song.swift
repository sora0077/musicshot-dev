//
//  Song.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Song: Entity {
    public typealias Identifier = Tagged<Song, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// The name of the album the song appears on.
    open var albumName: String { abstract() }
    /// The artist’s name.
    open var artistName: String { abstract() }
    /// The album artwork.
    open var artwork: Artwork { abstract() }
    /// (Optional) The song’s composer.
    open var composerName: String? { abstract() }
    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
    open var contentRating: String? { abstract() }
    /// The disc number the song appears on.
    open var discNumber: Int { abstract() }
    /// (Optional) The duration of the song in milliseconds.
    open var durationInMillis: Int? { abstract() }
    /// (Optional) The notes about the song that appear in the iTunes Store.
    open var editorialNotes: EditorialNotes { abstract() }
    /// The genre names the song is associated with.
    open var genreNames: [String] { abstract() }
    /// The ISRC (International Standard Recording Code) for the song.
    open var isrc: String { abstract() }
    /// (Optional, classical music only) The movement count of this song.
    open var movementCount: Int? { abstract() }
    /// (Optional, classical music only) The movement name of this song.
    open var movementName: String? { abstract() }
    /// (Optional, classical music only) The movement number of this song.
    open var movementNumber: Int? { abstract() }
    /// The localized name of the song.
    open var name: String { abstract() }
    /// (Optional) The parameters to use to playback the song.
    open var playParams: PlayParameters? { abstract() }
    /// The preview assets for the song.
    open var previews: [Preview] { abstract() }
    /// The release date of the music video in YYYY-MM-DD format.
    open var releaseDate: Date { abstract() }
    /// The number of the song in the album’s track list.
    open var trackNumber: Int { abstract() }
    /// The URL for sharing a song in the iTunes Store.
    open var url: URL { abstract() }
    /// (Optional, classical music only) The name of the associated work.
    open var workName: String? { abstract() }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    open var isInvalidated: Bool { abstract() }
}
