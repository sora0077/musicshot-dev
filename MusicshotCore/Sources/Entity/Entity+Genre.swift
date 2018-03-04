//
//  Entity+Genre.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit

extension Entity {
    @objc(Genre)
    public final class Genre: Object, AppleMusicKit.Genre {
        public typealias Identifier = String

        @objc public private(set) dynamic var id: Identifier = ""
        @objc public private(set) dynamic var name: String = ""

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(id: Identifier, name: String) throws {
            self.init()
            self.id = id
            self.name = name
        }
    }
}
