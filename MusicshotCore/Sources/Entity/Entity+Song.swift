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
    @objc(EntityArtwork)
    public final class Artwork: Object, AppleMusicKit.Artwork {
        @objc public private(set) dynamic var width: Int = -1
        @objc public private(set) dynamic var height: Int = -1
        @objc private dynamic var _url: String = ""

        @objc private dynamic var _bgColor: Int = -1
        @objc private dynamic var _textColor1: Int = -1
        @objc private dynamic var _textColor2: Int = -1
        @objc private dynamic var _textColor3: Int = -1
        @objc private dynamic var _textColor4: Int = -1

        @objc override public class func primaryKey() -> String? { return "_url" }

        public convenience init(
            width: Int,
            height: Int,
            url: String,
            colors: Artwork.Colors?
        ) throws {
            self.init()
            self.width = width
            self.height = height
            self._url = url

            let hex: (String?) -> Int = { $0.flatMap { Int($0, radix: 16) } ?? -1 }
            self._bgColor = hex(colors?.bgColor)
            self._textColor1 = hex(colors?.textColor1)
            self._textColor2 = hex(colors?.textColor2)
            self._textColor3 = hex(colors?.textColor3)
            self._textColor4 = hex(colors?.textColor4)
        }

        public func generater() -> (_ expectedWidth: Int) -> URL {
            let width = self.width
            let height = self.height
            let url = self._url
            return { expectedWidth in
                let ratio = CGFloat(height) / CGFloat(width)
                let expectedWidth = min(width, expectedWidth)
                let expectedHeight = Int(round(CGFloat(expectedWidth) * ratio))
                return URL(string: url
                    .replacingOccurrences(of: "{w}", with: "\(expectedWidth)")
                    .replacingOccurrences(of: "{h}", with: "\(expectedHeight)"))!
            }
        }

        public func url(for expectedWidth: Int) -> URL {
            return generater()(expectedWidth)
        }

        public func url(for width: CGFloat) -> URL {
            return url(for: Int(round(width)))
        }
    }

    @objc(EntityEditorialNotes)
    public final class EditorialNotes: Object, AppleMusicKit.EditorialNotes {
        @objc public private(set) dynamic var standard: String?
        @objc public private(set) dynamic var short: String?

        public convenience init(standard: String?, short: String?) throws {
            self.init()
            self.standard = standard
            self.short = short
        }
    }

    @objc(EntityPlayParameters)
    public final class PlayParameters: Object, AppleMusicKit.PlayParameters {
        @objc public private(set) dynamic var id: String = ""
        @objc public private(set) dynamic var kind: String = ""

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(id: String, kind: String) throws {
            self.init()
            self.id = id
            self.kind = kind
        }
    }
}

extension Entity {
    @objc(EntitySong)
    public final class Song: Object, AppleMusicKit.Song {
        public typealias Artwork = Entity.Artwork
        public typealias EditorialNotes = Entity.EditorialNotes
        public typealias PlayParameters = Entity.PlayParameters

        public typealias Identifier = Tagged<Song, String>

        public var id: Identifier { return Identifier(rawValue: _id) }
        @objc private dynamic var _id: String = ""
        @objc public private(set) dynamic var artistName: String = ""
        @objc public private(set) dynamic var composerName: String?
        @objc public private(set) dynamic var contentRating: String?
        @objc public private(set) dynamic var discNumber: Int = -1
        @objc public private(set) dynamic var editorialNotes: Entity.EditorialNotes?
        @objc public private(set) dynamic var movementName: String?
        @objc public private(set) dynamic var name: String = ""
        @objc public private(set) dynamic var playParams: Entity.PlayParameters?
        @objc public private(set) dynamic var trackNumber: Int = -1
        @objc public private(set) dynamic var workName: String?

        public var artwork: Entity.Artwork { return _artwork }
        @objc private dynamic var _artwork: Entity.Artwork!

        public var durationInMillis: Int? { return _durationInMillis.value }
        private let _durationInMillis = RealmOptional<Int>()

        public var genreNames: [String] { return Array(_genreNames) }
        private let _genreNames = List<String>()

        public var movementCount: Int? { return _movementCount.value }
        private let _movementCount = RealmOptional<Int>()

        public var movementNumber: Int? { return _movementNumber.value }
        private let _movementNumber = RealmOptional<Int>()

        @objc private dynamic var _releaseDate: String = ""

        public var url: URL { return URL(string: _url)! }
        @objc private dynamic var _url: String = ""

        public var preview: Preview? { return _preview.first }
        private let _preview = LinkingObjects(fromType: Preview.self, property: "song")

        @objc override public class func primaryKey() -> String? { return "_id" }

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
            self._id = id.rawValue
            self.artistName = artistName
            self._artwork = artwork
            self.composerName = composerName
            self.contentRating = contentRating
            self.discNumber = discNumber
            self._durationInMillis.value = durationInMillis
            self.editorialNotes = editorialNotes
            self._genreNames.append(objectsIn: genreNames)
            self._movementCount.value = movementCount
            self.movementName = movementName
            self._movementNumber.value = movementNumber
            self.name = name
            self.playParams = playParams
            self._releaseDate = releaseDate
            self.trackNumber = trackNumber
            self._url = url
            self.workName = workName
        }
    }

    @objc(EntityPreview)
    public final class Preview: Object {
        @objc public override class func primaryKey() -> String? { return "id" }

        @objc private(set) dynamic var id: Song.Identifier.RawValue = ""
        @objc private dynamic var _duration: Int = -1
        @objc private dynamic var _remoteUrl: String = ""
        @objc private dynamic var _localUrl: String = ""
        @objc private(set) dynamic var song: Song?

        public var duration: Int { return _duration }
        public var remoteURL: URL { return URL(string: _remoteUrl)! }
        @nonobjc public internal(set) var localURL: URL? {
            get { return URL(string: _localUrl) }
            set { _localUrl = newValue?.absoluteString ?? "" }
        }

        convenience init(song: Song, url: URL, duration: Int) {
            self.init()
            self.id = song.id.rawValue
            self._remoteUrl = url.absoluteString
            self._duration = duration
            self.song = song
        }
    }
}
