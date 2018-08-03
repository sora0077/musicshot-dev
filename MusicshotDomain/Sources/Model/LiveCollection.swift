//
//  LiveCollection.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/18.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class LiveCollection<Element>: Collection {
    public enum Change {
        case initial
        case update(deletions: [Int], insertions: [Int], modifications: [Int])
        case error(Error)
    }
    open class Token {
        public init() {}
    }

    public init() {}

    // MARK: -
    open func observe(_ event: @escaping (Change) -> Void) -> Token { abstract() }

    // MARK: - Collection confirmance
    open var startIndex: Int { abstract() }
    open var endIndex: Int { abstract() }

    open func index(after i: Int) -> Int { abstract() }

    open subscript (idx: Int) -> Element { abstract() }
}
