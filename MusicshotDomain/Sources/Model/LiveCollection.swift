//
//  LiveCollection.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/18.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

public enum LiveCollectionChange {
    case initial
    case update(deletions: [Int], insertions: [Int], modifications: [Int])
    case error(Error)
}

open class LiveCollectionToken {

    public init() {}
}

public protocol LiveCollection: Collection {

    func observe(_ event: @escaping (LiveCollectionChange) -> Void) -> LiveCollectionToken
}

private class _AnyLiveCollectionBase<Element>: LiveCollection {

    var startIndex: Int { fatalError() }
    var endIndex: Int { fatalError() }

    subscript (idx: Int) -> Element { fatalError() }
    func index(after i: Int) -> Int { fatalError() }

    func observe(_ event: @escaping (LiveCollectionChange) -> Void) -> LiveCollectionToken {
        fatalError()
    }
}

private class AnyLiveCollectionBase<C: LiveCollection>: _AnyLiveCollectionBase<C.Element> where C.Index == Int {

    private let base: C

    init(_ collection: C) {
        base = collection
    }

    override var startIndex: Int { return base.startIndex }
    override var endIndex: Int { return base.endIndex }

    override subscript (idx: Int) -> Element { return base[idx] }
    override func index(after i: Int) -> Int { return base.index(after: i) }

    override func observe(_ event: @escaping (LiveCollectionChange) -> Void) -> LiveCollectionToken {
        return base.observe(event)
    }
}

public final class AnyLiveCollection<Element>: LiveCollection {

    private let base: _AnyLiveCollectionBase<Element>

    public init<C: LiveCollection>(_ collection: C) where C.Element == Element, C.Index == Int {
        base = AnyLiveCollectionBase(collection)
    }

    // MARK: - Collection confirmance
    public var startIndex: Int { return base.startIndex }
    public var endIndex: Int { return base.endIndex }

    public subscript (idx: Int) -> Element { return base[idx] }
    public func index(after i: Int) -> Int { return base.index(after: i) }

    // MARK: -
    public func observe(_ event: @escaping (LiveCollectionChange) -> Void) -> LiveCollectionToken {
        return base.observe(event)
    }
}
