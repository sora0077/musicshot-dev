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

        @objc public dynamic var id: Identifier = ""
        @objc public dynamic var name: String = ""

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
        }
    }
}
