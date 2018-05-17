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
import MusicshotUtility

extension Entity {
    @objc(EntityArtist)
    public final class Artist: Object, AppleMusicKit.Artist {
        public typealias Identifier = Tagged<Artist, String>
        public typealias EditorialNotes = Entity.EditorialNotes

        public var id: Identifier { return Identifier(rawValue: _id) }
        @objc private dynamic var _id: String = ""
        @objc public private(set) dynamic var editorialNotes: Entity.EditorialNotes?
        @objc public private(set) dynamic var name: String = ""

        public var genreNames: [String] { return Array(_genreNames) }
        private let _genreNames = List<String>()

        @objc private dynamic var _url: String = ""

        @objc override public class func primaryKey() -> String? { return "_id" }

        public convenience init(
            id: Identifier,
            genreNames: [String],
            editorialNotes: Entity.EditorialNotes?,
            name: String,
            url: String
        ) throws {
            self.init()
            self._id = id.rawValue
            self._genreNames.append(objectsIn: genreNames)
            self.editorialNotes = editorialNotes
            self.name = name
            self._url = url
        }
    }
}
