//
//  Tagged.swift
//  AppleMusicKit
//
//  Created by 林達也 on 2018/04/23.
//  Copyright © 2018年 jp.sora0077. All rights reserved.
//

import Foundation

public struct Tagged<Tag, RawValue>: RawRepresentable {
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension Tagged: CustomStringConvertible where RawValue: CustomStringConvertible {
    public var description: String {
        return rawValue.description }
}

extension Tagged: CustomDebugStringConvertible where RawValue: CustomDebugStringConvertible {
    public var debugDescription: String { return rawValue.debugDescription }
}

extension Tagged: Equatable where RawValue: Equatable {
    public static func == (lhs: Tagged, rhs: Tagged) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Tagged: Comparable where RawValue: Comparable {
    public static func < (lhs: Tagged, rhs: Tagged) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension Tagged: Decodable where RawValue: Decodable {
    public init(from decoder: Decoder) throws {
        rawValue = try RawValue(from: decoder)
    }
}

extension Tagged: Encodable where RawValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension Tagged: ExpressibleByNilLiteral where RawValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        rawValue = RawValue(nilLiteral: nilLiteral)
    }
}

extension Tagged: ExpressibleByBooleanLiteral where RawValue: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = RawValue.BooleanLiteralType
    
    public init(booleanLiteral value: BooleanLiteralType) {
        rawValue = RawValue(booleanLiteral: value)
    }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = RawValue.IntegerLiteralType
    
    public init(integerLiteral value: IntegerLiteralType) {
        rawValue = RawValue(integerLiteral: value)
    }
}

extension Tagged: ExpressibleByFloatLiteral where RawValue: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = RawValue.FloatLiteralType
    
    public init(floatLiteral value: FloatLiteralType) {
        rawValue = RawValue(floatLiteral: value)
    }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
    public typealias StringLiteralType = RawValue.StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        rawValue = RawValue(stringLiteral: value)
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        rawValue = RawValue(unicodeScalarLiteral: value)
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        rawValue = RawValue(extendedGraphemeClusterLiteral: value)
    }
}
