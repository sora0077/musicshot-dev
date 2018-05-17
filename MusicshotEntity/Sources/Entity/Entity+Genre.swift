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
import MusicshotUtility

extension Entity {
    @objc(EntityGenre)
    public final class Genre: Object, AppleMusicKit.Genre {
        public typealias Identifier = Tagged<Genre, String>

        public var id: Identifier { return Identifier(rawValue: _id) }
        @objc private dynamic var _id: String = ""
        @objc public private(set) dynamic var name: String = ""

        @objc override public class func primaryKey() -> String? { return "_id" }

        public convenience init(id: Identifier, name: String) throws {
            self.init()
            self._id = id.rawValue
            self.name = name
        }
    }
}
