//
//  String.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/03.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

extension String {
    static func random(count: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<count {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
