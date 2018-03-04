//
//  Entity+Artist.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit

extension Entity {
    @objc(Artist)
    public final class Artist: Object, AppleMusicKit.Artist {
        public typealias EditorialNotes = Entity.EditorialNotes
        public typealias Identifier = String

        @objc public dynamic var id: Identifier = ""
        @objc public dynamic var name: String = ""

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(
            id: Identifier,
            genreNames: [String],
            editorialNotes: Entity.EditorialNotes?,
            name: String,
            url: String
        ) throws {
            self.init()
        }
    }
}
