//
//  Entity+Ranking.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/26.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotUtility

extension Entity.Ranking {
    @objc(EntityRankingGenre)
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

        @objc(EntityRankingGenreRssUrls)
        public final class RssUrls: RealmSwift.Object {
            @objc private dynamic var _topAlbums: String = ""
            @objc private dynamic var _topSongs: String = ""
            public override class func primaryKey() -> String? { return "_topAlbums" }

            public var topAlbums: URL { return URL(string: _topAlbums)! }
            public var topSongs: URL { return URL(string: _topSongs)! }

            convenience init(topAlbums: URL, topSongs: URL) {
                self.init()
                self._topAlbums = topAlbums.absoluteString
                self._topSongs = topSongs.absoluteString
            }
        }

        @objc(EntityRankingGenreChartUrls)
        public final class ChartUrls: RealmSwift.Object {
            @objc private dynamic var _albums: String = ""
            @objc private dynamic var _songs: String = ""
            public override class func primaryKey() -> String? { return "_albums" }

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

extension Entity.Ranking.Genre: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, name, url, rssUrls, chartUrls, subgenres
    }
    public convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(id: c.decode(String.self, forKey: .id),
                      name: c.decode(String.self, forKey: .name),
                      url: c.decode(URL.self, forKey: .url),
                      rssUrls: c.decode(Entity.Ranking.Genre.RssUrls.self, forKey: .rssUrls),
                      chartUrls: c.decode(Entity.Ranking.Genre.ChartUrls.self, forKey: .chartUrls),
                      subgenres: c.decodeIfPresent([String: Entity.Ranking.Genre].self, forKey: .subgenres)?.values.toArray())
    }
}

extension Entity.Ranking.Genre.RssUrls: Decodable {
    private enum CodingKeys: String, CodingKey {
        case topAlbums, topSongs
    }
    public convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(topAlbums: c.decode(URL.self, forKey: .topAlbums),
                      topSongs: c.decode(URL.self, forKey: .topSongs))
    }
}

extension Entity.Ranking.Genre.ChartUrls: Decodable {
    private enum CodingKeys: String, CodingKey {
        case albums, songs
    }
    public convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(albums: c.decode(URL.self, forKey: .albums),
                      songs: c.decode(URL.self, forKey: .songs))
    }
}
