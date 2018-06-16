//
//  Curator.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Curator: Entity {
    public typealias Identifier = Tagged<Curator, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// The curator artwork.
    open var artwork: Artwork { fatalError("abstract") }
    /// (Optional) The notes about the curator.
    open var editorialNotes: EditorialNotes? { fatalError("abstract") }
    /// The localized name of the curator.
    open var name: String { fatalError("abstract") }
    /// The URL for sharing a curator in Apple Music.
    open var url: URL { fatalError("abstract") }
}
