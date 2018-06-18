//
//  Entity.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/18.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import MusicshotDomain

protocol EntityConvertible: Entity {
    associatedtype Impl: EntityImplConvertible
}

protocol EntityImplConvertible: Entity {
    associatedtype Storage

    init(storage: Storage)
}
