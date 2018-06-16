//
//  Station.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Station: Entity {
    public typealias Identifier = Tagged<Station, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// The radio station artwork.
    open var artwork: Artwork { fatalError("abstract") }
    /// (Optional) The duration of the stream. Not emitted for 'live' or programmed stations.
    open var durationInMillis: Int? { fatalError("abstract") }
    /// (Optional) The notes about the station that appear in Apple Music.
    open var editorialNotes: EditorialNotes { fatalError("abstract") }
    /// (Optional) The episode number of the station. Only emitted when the station represents an episode of a show or other content.
    open var episodeNumber: String? { fatalError("abstract") }
    /// Indicates whether the station is a live stream.
    open var isLive: Bool { fatalError("abstract") }
    /// The localized name of the station.
    open var name: String { fatalError("abstract") }
    /// The URL for sharing a station in Apple Music.
    open var url: URL { fatalError("abstract") }
}
