//
//  Timeline.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/05/01.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol Timeline {
    associatedtype Element

    var count: Int { get }

    subscript (idx: Int) -> Element { get }

    func hasNext() -> Observable<Bool>

    func fetch() -> Single<Void>
}

class __AnyTimeline<E>: Timeline {
    typealias Element = E

    var count: Int { fatalError() }
    subscript (idx: Int) -> Element { fatalError() }

    func hasNext() -> Observable<Bool> { fatalError() }
    func fetch() -> Single<Void> { fatalError() }
}

final class _AnyTimeline<T: Timeline>: __AnyTimeline<T.Element> {
    typealias Element = T.Element

    override var count: Int { return timeline.count }

    override subscript (idx: Int) -> Element { return timeline[idx] }

    override func hasNext() -> Observable<Bool> { return timeline.hasNext() }

    override func fetch() -> Single<Void> { return timeline.fetch() }

    private let timeline: T

    fileprivate init(_ timeline: T) {
        self.timeline = timeline
    }
}

public final class AnyTimeline<E>: Timeline {
    public typealias Element = E

    public var count: Int { return timeline.count }

    public subscript (idx: Int) -> Element { return timeline[idx] }

    public func hasNext() -> Observable<Bool> { return timeline.hasNext() }

    public func fetch() -> Single<Void> { return timeline.fetch() }

    private let timeline: __AnyTimeline<E>

    public init<T: Timeline>(_ timeline: T) where T.Element == Element {
        self.timeline = _AnyTimeline(timeline)
    }
}
