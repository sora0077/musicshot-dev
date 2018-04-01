//
//  Resource+Search.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/15.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

extension Resource {
    public final class Search {
        @objc(SearchSongs)
        public final class Songs: Object, LifetimeObject {
            @objc private dynamic var pk: String = ""
            @objc private(set) dynamic var createDate = coeffects.dateType.now()
            @objc private(set) dynamic var updateDate = coeffects.dateType.now()

            @objc override public class func primaryKey() -> String? { return "pk" }

            @objc private(set) dynamic var fragment: SongsFragment?

            public let items = List<Entity.Song>()

            convenience init(uniqueKey: String) {
                self.init()
                pk = uniqueKey
            }

            convenience init(uniqueKey: String, _ newFragment: SongsFragment) {
                self.init()
                pk = uniqueKey
                replace(newFragment)
            }

            func replace(_ newFragment: SongsFragment?) {
                if fragment != newFragment || items.count != newFragment?.items.count {
                    items.removeAll()
                    if let newFragment = newFragment {
                        items.append(objectsIn: newFragment.items)
                    }
                }
                fragment = newFragment
            }

            func update(_ page: SearchResources.Page<Entity.Song>, _ newFragment: SongsFragment) throws {
                items.append(objectsIn: page.data.compactMap { $0.attributes })
                fragment = newFragment
                updateDate = coeffects.dateType.now()
            }
        }

        @objc(SearchSongsFragment)
        final class SongsFragment: Object, LifetimeObject {
            @objc private(set) dynamic var term: String = ""
            @objc private(set) dynamic var createDate = coeffects.dateType.now()
            @objc private(set) dynamic var updateDate = coeffects.dateType.now()

            @objc private(set) dynamic var next: InternalResource.Request?

            @objc override class func primaryKey() -> String? { return "term" }

            fileprivate let items = List<Entity.Song>()

            convenience init(term: String) {
                self.init()
                self.term = term
            }

            convenience init?(term: String, _ pages: SearchResources.Page<Entity.Song>?) throws {
                guard let pages = pages else { return nil }
                self.init()
                self.term = term
                items.append(objectsIn: pages.data.compactMap { $0.attributes })
                next = try InternalResource.Request(pages.next)
            }

            func update(_ page: SearchResources.Page<Entity.Song>) throws {
                if let old = next {
                    old.realm?.delete(old)
                }
                items.append(objectsIn: page.data.compactMap { $0.attributes })
                next = try InternalResource.Request(page.next)
                updateDate = coeffects.dateType.now()
            }

            static func == (lhs: SongsFragment, rhs: SongsFragment) -> Bool {
                return lhs.term == rhs.term
            }
        }
    }
}
