//
//  Entity.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/15.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
@_exported import Tagged

func abstract() -> Never {
    fatalError("abstract")
}

public protocol Identifiable: Hashable {
    associatedtype IdentifierTag
    associatedtype IdentifierRawValue
    typealias Identifier = Tagged<IdentifierTag, IdentifierRawValue>

    var id: Identifier { get }
}

extension Identifiable where Self.IdentifierRawValue: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Identifiable where Self.IdentifierRawValue: Hashable {
    public var hashValue: Int { return id.hashValue }
}

extension Sequence where Element: Identifiable {
    public var ids: [Element.Identifier] {
        return map { $0.id }
    }
}

extension Set where Element: Identifiable, Element.IdentifierRawValue: Hashable {
    public func mapped() -> [Element.Identifier: Element] {
        return Dictionary(uniqueKeysWithValues: map { ($0.id, $0) })
    }
}

extension Sequence where Element: RawRepresentable {
    public var rawValues: [Element.RawValue] {
        return map { $0.rawValue }
    }
}

//
// MARK: -
public protocol Entity: Identifiable {}

extension Entity {
    public typealias NotFound = DomainErrors.NotFound<Self>
}
