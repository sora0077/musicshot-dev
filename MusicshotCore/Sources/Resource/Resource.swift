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

public enum Resource {
    public enum Media {
        case song(Entity.Song)
        case album(Entity.Album)
        case musicVideo(Entity.MusicVideo)
    }

    @objc(Charts)
    public final class Charts: Object {
        @objc(ChartSongs)
        public final class Songs: Object {
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
}
