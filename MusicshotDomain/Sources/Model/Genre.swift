//
//  Genre.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Genre {
    public init() {}

    /// The localized name of the genre.
    open var name: String { fatalError("abstract") }
}
