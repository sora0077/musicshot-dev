//
//  ListRankingGenres.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/26.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import APIKit
import FoundationSupport

struct ListRankingGenres: Request {
    let method = HTTPMethod.get
    let baseURL: URL = URL(string: "https://itunes.apple.com")!
    let path: String = "WebObjects/MZStoreServices.woa/ws/genres"
    let country: String?
    var queryParameters: [String: Any]? {
        return [
            "id": 34,  // music
            "cc": country
        ].compactValues()
    }
    var dataParser: DataParser {
        struct DataParser: APIKit.DataParser {
            var contentType: String? = "application/json"

            func parse(data: Data) throws -> Any {
                return data
            }
        }
        return DataParser()
    }

    init(country: String? = Locale.current.regionCode) {
        self.country = country
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Entity.Ranking.Genre {
        // swiftlint:disable:next force_cast
        return try JSONDecoder().decode([String: Entity.Ranking.Genre].self, from: object as! Data).values.first!
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
                      subgenres: c.decodeIfPresent([String: Entity.Ranking.Genre].self,
                                                   forKey: .subgenres)?.values.toArray())
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

private extension Sequence {
    func toArray() -> [Element] {
        return Array(self)
    }
}
