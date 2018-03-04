//
//  Entity+Album.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit

extension Entity {
    @objc(Album)
    public final class Album: Object, AppleMusicKit.Album {
        public typealias Artwork = Entity.Artwork
        public typealias EditorialNotes = Entity.EditorialNotes
        public typealias PlayParameters = Entity.PlayParameters
        public typealias Identifier = String

        @objc public dynamic var id: Identifier = ""
        @objc public dynamic var name: String = ""

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(
            id: Identifier,
            artistName: String,
            artwork: Entity.Artwork,
            contentRating: String?,
            copyright: String,
            editorialNotes: Entity.EditorialNotes?,
            genreNames: [String],
            isComplete: Bool,
            isSingle: Bool,
            name: String,
            releaseDate: String,
            playParams: Entity.PlayParameters?,
            trackCount: Int,
            url: String
        ) throws {
            self.init()
        }
    }
}
