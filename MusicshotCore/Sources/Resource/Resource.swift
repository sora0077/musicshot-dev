//
//  Resource.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/10.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit
import SwiftDate

protocol LifetimeObject {
    var createDate: Date { get }
    var updateDate: Date { get }
}

extension Realm {
    func object<O: Object & LifetimeObject, Key>(
        of type: O.Type, for primaryKey: Key,
        _ keyPath: KeyPath<O, Date>, within: DateComponents,
        now: Date = coeffects.dateType.now()
    ) -> O? {
        let obj = object(ofType: type, forPrimaryKey: primaryKey)
        if let date = obj?[keyPath: keyPath], date < now - within {
            return nil
        }
        return obj
    }
}

public enum Resource {
    public enum Media {
        case song(Entity.Song)
        case album(Entity.Album)
        case musicVideo(Entity.MusicVideo)
    }

    public enum Ranking {
        @objc(RankingGenre)
        public final class Genre: Object {
            @objc public private(set) dynamic var id: String = ""
            @objc public private(set) dynamic var name: String = ""
            @objc private dynamic var _url: String = ""
            @objc private dynamic var _rssUrls: RssUrls?
            @objc private dynamic var _chartUrls: ChartUrls?

            public var url: URL { return URL(string: _url)! }
            public var rssUrls: RssUrls { return _rssUrls! }
            public var chartUrls: ChartUrls { return _chartUrls! }

            public let subgenres = List<Genre>()
            public override class func primaryKey() -> String? { return "id" }

            @objc(RankingGenreRssUrls)
            public final class RssUrls: RealmSwift.Object {
                @objc private dynamic var _topAlbums: String = ""
                @objc private dynamic var _topSongs: String = ""

                public var topAlbums: URL { return URL(string: _topAlbums)! }
                public var topSongs: URL { return URL(string: _topSongs)! }

                convenience init(topAlbums: URL, topSongs: URL) {
                    self.init()
                    self._topAlbums = topAlbums.absoluteString
                    self._topSongs = topSongs.absoluteString
                }
            }

            @objc(RankingGenreChartUrls)
            public final class ChartUrls: RealmSwift.Object {
                @objc private dynamic var _albums: String = ""
                @objc private dynamic var _songs: String = ""

                public var albums: URL { return URL(string: _albums)! }
                public var songs: URL { return URL(string: _songs)! }

                convenience init(albums: URL, songs: URL) {
                    self.init()
                    self._albums = albums.absoluteString
                    self._songs = songs.absoluteString
                }
            }

            convenience init(
                id: String,
                name: String,
                url: URL,
                rssUrls: RssUrls,
                chartUrls: ChartUrls,
                subgenres: [Genre]?
            ) {
                self.init()
                self.id = id
                self.name = name
                self._url = url.absoluteString
                self._rssUrls = rssUrls
                self._chartUrls = chartUrls
                self.subgenres.append(objectsIn: subgenres ?? [])
            }
        }
    }
}

enum InternalResource {
    @objc(StorefrontHolder)
    final class StorefrontHolder: Object {
        let list = List<Entity.Storefront>()
    }

    @objc(SelectedStorefront)
    final class SelectedStorefront: Object {
        @objc dynamic var storefront: Entity.Storefront?
    }

    @objc(Media)
    final class Media: Object {
        @objc dynamic var song: Entity.Song?
        @objc dynamic var musicVideo: Entity.Song?
        @objc dynamic var album: Entity.Album?
    }

    @objc(Request)
    final class Request: Object {
        @objc dynamic var path: String = ""
        @objc dynamic var parameters: String?

        convenience init?<Req: PaginatorRequest>(_ request: Req?) throws {
            guard let request = request else { return nil }
            self.init()
            path = request.path
            parameters = try request.parameters
                .flatMap { $0 as? [AnyHashable: Any] }
                .map { $0.mapValues { value -> Any in
                    if let str = value as? String {
                        return str.removingPercentEncoding ?? str
                    } else {
                        return value
                    }
                }}
                .map { try JSONSerialization.data(withJSONObject: $0, options: []) }
                .flatMap { String(data: $0, encoding: .utf8) }
        }

        func asRequest<Req: PaginatorRequest>() throws -> Req {
            return Req.init(path: path, parameters: try parameters
                .flatMap { $0.data(using: .utf8) }
                .map { try JSONSerialization.jsonObject(with: $0, options: []) }
                as? [String: Any] ?? [:])
        }
    }

    @objc(Histories)
    final class Histories: Object {
        let list = List<Entity.History>()
    }
}
