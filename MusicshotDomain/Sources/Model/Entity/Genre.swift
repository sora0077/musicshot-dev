//
//  Genre.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Genre: Entity {
    public typealias Identifier = Tagged<Genre, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier
    /// The localized name of the genre.
    open var name: String { fatalError("abstract") }
}
