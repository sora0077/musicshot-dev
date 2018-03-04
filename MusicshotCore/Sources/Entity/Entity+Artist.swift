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

        @objc public private(set) dynamic var id: Identifier = ""
        @objc public private(set) dynamic var editorialNotes: Entity.EditorialNotes?
        @objc public private(set) dynamic var name: String = ""

        public var genreNames: [String] { return Array(_genreNames) }
        private let _genreNames = List<String>()

        @objc private dynamic var _url: String = ""

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(
            id: Identifier,
            genreNames: [String],
            editorialNotes: Entity.EditorialNotes?,
            name: String,
            url: String
        ) throws {
            self.init()
            self.id = id
            self._genreNames.append(objectsIn: genreNames)
            self.editorialNotes = editorialNotes
            self.name = name
            self._url = url
        }
    }
}
