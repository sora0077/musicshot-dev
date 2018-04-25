//
//  ListRankingRss.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/04/26.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import APIKit
import FoundationSupport

struct ListRankingRss: Request {
    let method = HTTPMethod.get
    let baseURL: URL
    let path: String
    var dataParser: DataParser {
        struct DataParser: APIKit.DataParser {
            var contentType: String? = "application/json"

            func parse(data: Data) throws -> Any {
                return data
            }
        }
        return DataParser()
    }

    init(url: URL, limit: Int = 200) {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        comps.path = ""
        baseURL = comps.url!

        var paths = url.path.components(separatedBy: "/")
        paths.insert("limit=\(limit)", at: paths.count - 1)
        path = paths.joined(separator: "/")
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Entity.Song.Identifier] {
        // swiftlint:disable:next force_cast
        return try JSONDecoder().decode(Root.self, from: object as! Data).feed.entry.map { $0.id.attributes.id }
    }
}

private struct Root: Decodable {
    let feed: Feed

    struct Feed: Decodable {
        let entry: [Entry]

        struct Entry: Decodable {
            let id: Id

            struct Id: Decodable {
                let attributes: Attributes

                struct Attributes: Decodable {
                    let id: Entity.Song.Identifier

                    private enum CodingKeys: String, CodingKey {
                        case id = "im:id"
                    }
                }
            }
        }
    }
}
