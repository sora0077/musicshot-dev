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
    @objc(EntityAlbum)
    public final class Album: Object, AppleMusicKit.Album {
        public typealias Artwork = Entity.Artwork
        public typealias EditorialNotes = Entity.EditorialNotes
        public typealias PlayParameters = Entity.PlayParameters
        public typealias Identifier = String

        @objc public private(set) dynamic var id: Identifier = ""
        @objc public private(set) dynamic var artistName: String = ""
        @objc public private(set) dynamic var contentRating: String?
        @objc public private(set) dynamic var copyright: String = ""
        @objc public private(set) dynamic var editorialNotes: Entity.EditorialNotes?
        @objc public private(set) dynamic var isComplete: Bool = false
        @objc public private(set) dynamic var isSingle: Bool = false
        @objc public private(set) dynamic var name: String = ""
        @objc public private(set) dynamic var playParams: Entity.PlayParameters?
        @objc public private(set) dynamic var trackCount: Int = -1

        public var artwork: Entity.Artwork { return _artwork }
        @objc private dynamic var _artwork: Entity.Artwork!

        public var genreNames: [String] { return Array(_genreNames) }
        private let _genreNames = List<String>()

        public var trackNumber: Int? { return _trackNumber.value }
        private let _trackNumber = RealmOptional<Int>()

        @objc private dynamic var _releaseDate: String = ""

        @objc private dynamic var _url: String = ""

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
            self.id = id
            self.artistName = artistName
            self._artwork = artwork
            self.contentRating = contentRating
            self.copyright = copyright
            self.editorialNotes = editorialNotes
            self._genreNames.append(objectsIn: genreNames)
            self.isComplete = isComplete
            self.isSingle = isSingle
            self.name = name
            self.playParams = playParams
            self._releaseDate = releaseDate
            self.trackCount = trackCount
            self._url = url
        }
    }
}
