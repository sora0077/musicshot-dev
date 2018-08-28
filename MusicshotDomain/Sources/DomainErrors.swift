//
//  DomainErrors.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/08/06.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

public enum DomainErrors {
    public struct NotFound<Element>: Error {
        public init() {}
    }
}
