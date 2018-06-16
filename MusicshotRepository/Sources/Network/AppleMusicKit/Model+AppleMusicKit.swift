//
//  Model+AppleMusicKit.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AppleMusicKit

extension ActivityImpl.Storage: Activity {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage

    convenience init(id: Identifier,
                     artwork: Artwork,
                     editorialNotes: EditorialNotes?,
                     name: String,
                     url: String) throws {
        self.init()
        self.id = id
        self.artwork = artwork
        self.editorialNotes = editorialNotes
        self.name = name
        self.url = url
    }
}

extension AlbumImpl.Storage: Album {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage
    typealias PlayParameters = PlayParametersImpl.Storage

    convenience init(id: Identifier,
                     albumName: String?,
                     artistName: String,
                     artwork: Artwork,
                     contentRating: String?,
                     copyright: String,
                     editorialNotes: EditorialNotes?,
                     genreNames: [String],
                     isComplete: Bool,
                     isSingle: Bool,
                     name: String,
                     recordLabel: String,
                     releaseDate: String,
                     playParams: PlayParameters?,
                     trackCount: Int,
                     url: String) throws {
        self.init()
        self.id = id
        self.albumName = albumName
        self.artistName = artistName
        self.artwork = artwork
        self.contentRating = contentRating
        self.copyright = copyright
        self.editorialNotes = editorialNotes
        self.genreNames.append(objectsIn: genreNames)
        self.isComplete = isComplete
        self.isSingle = isSingle
        self.name = name
        self.recordLabel = recordLabel
//        self.releaseDate = releaseDate
        self.playParams = playParams
        self.trackCount = trackCount
        self.url = url
    }
}

extension AppleCuratorImpl.Storage: AppleCurator {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage

    convenience init(id: Identifier,
                     artwork: Artwork,
                     editorialNotes: EditorialNotes?,
                     name: String,
                     url: String) throws {
        self.init()
        self.id = id
        self.artwork = artwork
        self.editorialNotes = editorialNotes
        self.name = name
        self.url = url
    }
}

extension ArtistImpl.Storage: Artist {
    typealias Identifier = String
    typealias EditorialNotes = EditorialNotesImpl.Storage

    convenience init(id: Identifier,
                     genreNames: [String],
                     editorialNotes: EditorialNotes?,
                     name: String,
                     url: String) throws {
        self.init()
        self.id = id
        self.genreNames.append(objectsIn: genreNames)
        self.editorialNotes = editorialNotes
        self.name = name
        self.url = url
    }
}

extension ArtworkImpl.Storage: Artwork {

    convenience init(width: Int,
                     height: Int,
                     url: String,
                     colors: Colors?) throws {
        self.init()
        self.width = width
        self.height = height
        self.url = url
        self.bgColor.value =  colors.flatMap { Int($0.bgColor, radix: 16) }
        self.textColor1.value =  colors.flatMap { Int($0.textColor1, radix: 16) }
        self.textColor2.value =  colors.flatMap { Int($0.textColor2, radix: 16) }
        self.textColor3.value =  colors.flatMap { Int($0.textColor3, radix: 16) }
        self.textColor4.value =  colors.flatMap { Int($0.textColor4, radix: 16) }
    }
}

extension CuratorImpl.Storage: Curator {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage

    convenience init(id: Identifier,
                     artwork: Artwork,
                     editorialNotes: EditorialNotes?,
                     name: String,
                     url: String) throws {
        self.init()
        self.id = id
        self.artwork = artwork
        self.editorialNotes = editorialNotes
        self.name = name
        self.url = url
    }
}

extension EditorialNotesImpl.Storage: EditorialNotes {

    convenience init(standard: String?,
                     short: String?) throws {
        self.init()
        self.standard = standard ?? ""
        self.short = short ?? ""
    }
}

extension GenreImpl.Storage: Genre {
    typealias Identifier = String

    convenience init(id: Identifier,
                     name: String) throws {
        self.init()
        self.id = id
        self.name = name
    }
}

extension MusicVideoImpl.Storage: MusicVideo {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage
    typealias PlayParameters = PlayParametersImpl.Storage
    typealias Preview = PreviewImpl.Storage

    convenience init(id: Identifier,
                     albumName: String?,
                     artistName: String,
                     artwork: Artwork,
                     contentRating: String?,
                     durationInMillis: Int?,
                     editorialNotes: EditorialNotes?,
                     genreNames: [String],
                     isrc: String,
                     name: String,
                     playParams: PlayParameters?,
                     previews: [Preview],
                     releaseDate: String,
                     trackNumber: Int?,
                     url: String,
                     videoSubType: String?) throws {
        self.init()
        self.id = id
        self.albumName = albumName
        self.artistName = artistName
        self.artwork = artwork
        self.contentRating = contentRating
        self.durationInMillis.value = durationInMillis
        self.editorialNotes = editorialNotes
        self.genreNames.append(objectsIn: genreNames)
        self.isrc = isrc
        self.name = name
        self.playParams = playParams
        self.previews.append(objectsIn: previews)
//        self.releaseDate = releaseDate
        self.trackNumber.value = trackNumber
        self.url = url
        self.videoSubType = videoSubType
    }
}

extension PlaylistImpl.Storage: Playlist {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage
    typealias PlayParameters = PlayParametersImpl.Storage

    convenience init(id: Identifier,
                     artwork: Artwork?,
                     curatorName: String?,
                     description: EditorialNotes?,
                     lastModifiedDate: String,
                     name: String,
                     playlistType: PlaylistType,
                     playParams: PlayParameters?,
                     url: String) throws {
        self.init()
        self.id = id
        self.artwork = artwork
        self.curatorName = curatorName
        self.editorialNotes = description
//        self.lastModifiedDate = lastModifiedDate
        self.name = name
        self.playlistType = playlistType.rawValue
        self.playParams = playParams
        self.url = url
    }
}

extension PlayParametersImpl.Storage: PlayParameters {

    convenience init(id: String,
                     kind: String) throws {
        self.init()
        self.id = id
        self.kind = kind
    }
}

extension PreviewImpl.Storage: Preview {
    typealias Artwork = ArtworkImpl.Storage

    convenience init(url: String,
                     artwork: Artwork?) throws {
        self.init()
        self.url = url
        self.artwork = artwork
    }
}

extension SongImpl.Storage: Song {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage
    typealias PlayParameters = PlayParametersImpl.Storage
    typealias Preview = PreviewImpl.Storage

    convenience init(id: Identifier,
                     albumName: String,
                     artistName: String,
                     artwork: Artwork,
                     composerName: String?,
                     contentRating: String?,
                     discNumber: Int,
                     durationInMillis: Int?,
                     editorialNotes: EditorialNotes?,
                     genreNames: [String],
                     isrc: String,
                     movementCount: Int?,
                     movementName: String?,
                     movementNumber: Int?,
                     name: String,
                     playParams: PlayParameters?,
                     previews: [Preview],
                     releaseDate: String,
                     trackNumber: Int,
                     url: String,
                     workName: String?) throws {
        self.init()
        self.id = id
        self.albumName = albumName
        self.artistName = artistName
        self.artwork = artwork
        self.contentRating = contentRating
        self.discNumber = discNumber
        self.durationInMillis.value = durationInMillis
        self.editorialNotes = editorialNotes
        self.genreNames.append(objectsIn: genreNames)
        self.isrc = isrc
        self.movementCount.value = movementCount
        self.movementName = movementName
        self.movementNumber.value = movementNumber
        self.name = name
        self.playParams = playParams
        self.previews.append(objectsIn: previews)
//        self.releaseDate = releaseDate
        self.trackNumber = trackNumber
        self.url = url
        self.workName = workName
    }
}

extension StationImpl.Storage: Station {
    typealias Identifier = String
    typealias Artwork = ArtworkImpl.Storage
    typealias EditorialNotes = EditorialNotesImpl.Storage

    convenience init(id: Identifier,
                     artwork: Artwork,
                     durationInMillis: Int?,
                     editorialNotes: EditorialNotes?,
                     episodeNumber: Int?,
                     isLive: Bool,
                     name: String,
                     url: String) throws {
        self.init()
        self.id = id
        self.artwork = artwork
        self.durationInMillis.value = durationInMillis
        self.editorialNotes = editorialNotes
        self.episodeNumber.value = episodeNumber
        self.isLive = isLive
        self.name = name
        self.url = url
    }
}

extension String: Language {}

extension StorefrontImpl.Storage: Storefront {
    typealias Identifier = String
    typealias Language = String

    convenience init(id: Identifier,
                     defaultLanguageTag: Language,
                     name: String,
                     supportedLanguageTags: [Language]) throws {
        self.init()
        self.id = id
        self.defaultLanguageTag = defaultLanguageTag
        self.name = name
        self.supportedLanguageTags.append(objectsIn: supportedLanguageTags)
    }
}
