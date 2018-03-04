//
//  Entity+MusicVideo.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit

extension Entity {
    @objc(MusicVideo)
    public final class MusicVideo: Object, AppleMusicKit.MusicVideo {
        public typealias Artwork = Entity.Artwork
        public typealias EditorialNotes = Entity.EditorialNotes
        public typealias PlayParameters = Entity.PlayParameters
        public typealias Identifier = String

        @objc public private(set) dynamic var id: Identifier = ""
        @objc public private(set) dynamic var artistName: String = ""
        @objc public private(set) dynamic var contentRating: String?
        @objc public private(set) dynamic var editorialNotes: Entity.EditorialNotes?
        @objc public private(set) dynamic var name: String = ""
        @objc public private(set) dynamic var playParams: Entity.PlayParameters?

        public var artwork: Entity.Artwork { return _artwork }
        @objc private dynamic var _artwork: Entity.Artwork!

        public var durationInMillis: Int? { return _durationInMillis.value }
        private let _durationInMillis = RealmOptional<Int>()

        public var genreNames: [String] { return Array(_genreNames) }
        private let _genreNames = List<String>()

        public var trackNumber: Int? { return _trackNumber.value }
        private let _trackNumber = RealmOptional<Int>()

        @objc private dynamic var _releaseDate: String = ""

        @objc private dynamic var _url: String = ""

        @objc private dynamic var _videoSubType: String?

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(
            id: String,
            artistName: String,
            artwork: Entity.Artwork,
            contentRating: String?,
            durationInMillis: Int?,
            editorialNotes: Entity.EditorialNotes?,
            genreNames: [String],
            name: String,
            playParams: Entity.PlayParameters?,
            releaseDate: String,
            trackNumber: Int?,
            url: String,
            videoSubType: String?
        ) throws {
            self.init()
            self.id = id
            self.artistName = artistName
            self._artwork = artwork
            self.contentRating = contentRating
            self._durationInMillis.value = durationInMillis
            self.editorialNotes = editorialNotes
            self._genreNames.append(objectsIn: genreNames)
            self.name = name
            self.playParams = playParams
            self._releaseDate = releaseDate
            self._trackNumber.value = trackNumber
            self._url = url
            self._videoSubType = videoSubType
        }
    }
}
