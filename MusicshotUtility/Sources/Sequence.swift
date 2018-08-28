//
//  Sequence.swift
//  MusicshotUtility
//
//  Created by 林達也 on 2018/05/17.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

extension Sequence {
    public func toArray() -> [Element] {
        return Array(self)
    }
}

extension Set {
    public static func - (lhs: Set, rhs: Set) -> Set {
        return lhs.subtracting(rhs)
    }

    public static func - <S: Sequence>(lhs: Set, rhs: S) -> Set where S.Element == Element {
        return lhs.subtracting(rhs)
    }
}
