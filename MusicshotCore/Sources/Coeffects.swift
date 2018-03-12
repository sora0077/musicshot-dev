//
//  Coeffects.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/12.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

struct Coeffects {
    var dateType: DateProtocol.Type
}

var coeffects = Coeffects(
    dateType: Date.self)

// MARK: -
protocol DateProtocol {
    static func now() -> Date
}

extension Date: DateProtocol {
    static func now() -> Date {
        return Date()
    }
}
