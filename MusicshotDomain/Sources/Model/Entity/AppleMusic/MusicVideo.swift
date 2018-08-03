//
//  MusicVideo.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class MusicVideo: Entity {
    public typealias Identifier = Tagged<MusicVideo, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// (Optional) The name of the album the music video appears on.
    open var albumName: String? { abstract() }
    /// The artist’s name.
    open var artistName: String { abstract() }
    /// The artwork for the music video’s associated album.
    open var artwork: Artwork { abstract() }
    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
    open var contentRating: String? { abstract() }
    /// (Optional) The duration of the music video in milliseconds.
    open var durationInMillis: Int? { abstract() }
    /// (Optional) The editorial notes for the music video.
    open var editorialNotes: EditorialNotes { abstract() }
    /// The music video’s associated genres.
    open var genreNames: [String] { abstract() }
    /// The ISRC (International Standard Recording Code) for the music video.
    open var isrc: String { abstract() }
    /// The localized name of the music video.
    open var name: String { abstract() }
    /// (Optional) The parameters to use to playback the music video.
    open var playParams: PlayParameters? { abstract() }
    /// The preview assets for the music video.
    open var previews: [Preview] { abstract() }
    /// The release date of the music video in YYYY-MM-DD format.
    open var releaseDate: Date { abstract() }
    /// (Optional) The number of the music video in the album’s track list.
    open var trackNumber: Int? { abstract() }
    /// A clear url directly to the music video.
    open var url: URL { abstract() }
    /// (Optional) The video subtype associated with the content.
    open var videoSubType: String? { abstract() }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    open var isInvalidated: Bool { abstract() }
}
