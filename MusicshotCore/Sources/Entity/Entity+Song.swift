//
//  Entity+Song.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit

extension Entity {
    @objc(Artwork)
    public final class Artwork: Object, AppleMusicKit.Artwork {
        public convenience init(
            width: Int,
            height: Int,
            url: String,
            colors: Artwork.Colors?
        ) throws {
            self.init()
        }
    }

    @objc(EditorialNotes)
    public final class EditorialNotes: Object, AppleMusicKit.EditorialNotes {
        public convenience init(standard: String?, short: String?) throws {
            self.init()
        }
    }

    @objc(PlayParameters)
    public final class PlayParameters: Object, AppleMusicKit.PlayParameters {
        public convenience init(id: String, kind: String) throws {
            self.init()
        }
    }
}

extension Entity {
    @objc(Song)
    public final class Song: Object, AppleMusicKit.Song {
        public typealias Artwork = Entity.Artwork
        public typealias EditorialNotes = Entity.EditorialNotes
        public typealias PlayParameters = Entity.PlayParameters

        public typealias Identifier = String

        public convenience init(
            id: Identifier,
            artistName: String,
            artwork: Entity.Artwork,
            composerName: String?,
            contentRating: String?,
            discNumber: Int,
            durationInMillis: Int?,
            editorialNotes: Entity.EditorialNotes?,
            genreNames: [String],
            movementCount: Int?,
            movementName: String?,
            movementNumber: Int?,
            name: String,
            playParams: Entity.PlayParameters?,
            releaseDate: String,
            trackNumber: Int,
            url: String,
            workName: String?
        ) throws {
            self.init()
        }
    }
}
