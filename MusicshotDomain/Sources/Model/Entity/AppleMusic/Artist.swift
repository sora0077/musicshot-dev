//
//  Artist.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Artist: Entity {
    public typealias Identifier = Tagged<Artist, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// The names of the genres associated with this artist.
    open var genreNames: [String] { abstract() }
    /// (Optional) The notes about the artist that appear in the iTunes Store.
    open var editorialNotes: EditorialNotes { abstract() }
    /// The localized name of the curator.
    open var name: String { abstract() }
    /// The URL for sharing an curator in the iTunes Store.
    open var url: URL { abstract() }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    open var isInvalidated: Bool { abstract() }
}
