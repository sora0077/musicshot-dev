//
//  AppleCurator.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class AppleCurator: Entity {
    public typealias Identifier = Tagged<AppleCurator, String>

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier

    public init(id: Identifier) {
        self.id = id
    }

    /// The curator artwork.
    open var artwork: Artwork { fatalError("abstract") }
    /// (Optional) The notes about the curator that appear in the iTunes Store.
    open var editorialNotes: EditorialNotes? { fatalError("abstract") }
    /// The localized name of the curator.
    open var name: String { fatalError("abstract") }
    /// The URL for sharing an curator in the iTunes Store.
    open var url: URL { fatalError("abstract") }
}
