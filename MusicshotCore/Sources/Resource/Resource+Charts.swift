//
//  Resource+Charts.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/22.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift

extension Resource {
    public final class Charts {
        @objc(ChartSongs)
        public final class Songs: Object, LifetimeObject {
            @objc private dynamic var pk: String = ""
            @objc public private(set) dynamic var name: String = ""
            @objc public private(set) dynamic var chart: String = ""
            @objc public private(set) dynamic var href: String?

            @objc private(set) dynamic var next: InternalResource.Request?

            @objc private(set) dynamic var createDate = coeffects.dateType.now()
            @objc private(set) dynamic var updateDate = coeffects.dateType.now()

            public let items = List<Entity.Song>()

            @objc override public class func primaryKey() -> String? { return "pk" }

            convenience init(chart: String?) {
                self.init()
                pk = chart ?? ""
            }

            convenience init?(_ songs: GetCharts.Page<Entity.Song>?, isDefault: Bool) throws {
                guard let songs = songs else { return nil }
                self.init()
                pk = isDefault ? "" : songs.chart
                name = songs.name
                chart = songs.chart
                href = songs.href
                items.append(objectsIn: songs.data.compactMap { $0.attributes })
                next = try InternalResource.Request(songs.next)
            }

            func update(_ songs: GetCharts.Page<Entity.Song>) throws {
                if let old = next {
                    old.realm?.delete(old)
                }
                items.append(objectsIn: songs.data.flatMap { $0.attributes })
                next = try InternalResource.Request(songs.next)
                updateDate = coeffects.dateType.now()
            }
        }
        @objc(ChartAlbums)
        public final class Albums: Object {
            @objc public private(set) dynamic var name: String = ""
            @objc public private(set) dynamic var chart: String = ""
        }
    }
}
