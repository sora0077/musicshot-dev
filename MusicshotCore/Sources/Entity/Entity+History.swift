//
//  Entity+History.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/21.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit

extension Entity {
    @objc(EntityHistory)
    public final class History: Object {
        @objc public private(set) dynamic var song: Entity.Song?
        @objc public private(set) dynamic var createDate = coeffects.dateType.now()

        convenience init(_ song: Entity.Song) {
            self.init()
            self.song = song
        }
    }
}
