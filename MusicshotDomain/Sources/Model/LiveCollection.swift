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
        case initial(LiveCollection<Element>)
        case update(LiveCollection<Element>, deletions: [Int], insertions: [Int], modifications: [Int])
        case error(Error)
    }

    open class Token {
        public init() {}
    }

    public init() {}

    open func observe(_ event: @escaping (Change) -> Void) -> Token { fatalError() }

    // MARK: - Collection confirmance
    open var startIndex: Int { fatalError() }
    open var endIndex: Int { fatalError() }

    open subscript (idx: Int) -> Element { fatalError() }
    open func index(after i: Int) -> Int { fatalError() }
}
