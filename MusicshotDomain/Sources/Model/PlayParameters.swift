//
//  PlayParameters.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class PlayParameters: Entity {
    public typealias Identifier = Tagged<PlayParameters, String>

    /// The ID of the content to use for playback.
    public let id: Identifier

    public init(id: Identifier) {
        self.id = id
    }

    /// The kind of the content to use for playback.
    open var kind: String { fatalError("abstract") }
}
