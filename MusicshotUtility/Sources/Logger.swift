//
//  Logger.swift
//  MusicshotUtility
//
//  Created by 林達也 on 2018/04/23.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import Crashlytics

public struct Logger {
    public init() {}
    
    public func error(_ error: Error, _ file: StaticString = #file, _ line: UInt = #line) {
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["file": file, "line": line])
        print(file, line, error)
    }
}
