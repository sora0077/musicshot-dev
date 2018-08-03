//
//  PlayParameters.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class PlayParameters: Entity {
    public typealias Identifier = Tagged<PlayParameters, String>

    public init(id: Identifier) {
        self.id = id
    }

    /// The ID of the content to use for playback.
    public let id: Identifier
    /// The kind of the content to use for playback.
    open var kind: String { abstract() }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    open var isInvalidated: Bool { abstract() }
}
