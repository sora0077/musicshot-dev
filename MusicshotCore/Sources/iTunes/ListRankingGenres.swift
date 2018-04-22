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
