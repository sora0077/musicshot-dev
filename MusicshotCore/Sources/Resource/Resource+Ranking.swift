//
//  Resource+Ranking.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/26.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift

extension Resource {
    public final class Ranking {
        @objc(RankingGenre)
        public final class Genre: Object {
            @objc override public class func primaryKey() -> String? { return "pk" }

            @objc private dynamic var pk: String = ""
            @objc private dynamic var _genre: Entity.Ranking.Genre?
            @objc public internal(set) dynamic var isSelected: Bool = true

            public var genre: Entity.Ranking.Genre { return _genre! }

            fileprivate convenience init(_ genre: Entity.Ranking.Genre) {
                self.init()
                self.pk = genre.id
                self._genre = genre
            }
        }

        @objc(RankingGenreSongs)
        public final class GenreSongs: Object, LifetimeObject {
            @objc override public class func primaryKey() -> String? { return "_id" }

            @objc private dynamic var _id: String = ""

            @objc private(set) dynamic var createDate = coeffects.dateType.now()
            @objc private(set) dynamic var updateDate = coeffects.dateType.now()

            public let items = List<Entity.Song>()

            convenience init(id: Entity.Genre.Identifier) {
                self.init()
                _id = id.rawValue
            }
        }

        @objc(RankingGenres)
        public final class Genres: Object, LifetimeObject {
            @objc override public class func primaryKey() -> String? { return "pk" }

            @objc private dynamic var pk: String = ""

            @objc private(set) dynamic var createDate = coeffects.dateType.now()
            @objc private(set) dynamic var updateDate = coeffects.dateType.now()

            private let _items = List<Genre>()

            func append(_ genre: Entity.Ranking.Genre) {
                let genre = Genre(genre)
                realm?.add(genre, update: true)
                _items.append(genre)
            }

            func removeAll() {
                _items.removeAll()
            }

            func items() -> Results<Genre> {
                return _items.filter("isSelected = true AND _genre != nil")
            }
        }
    }
}
