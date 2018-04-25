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
        _ keyPath: KeyPath<O, Date>,
        within: DateComponents,
        now: Date = coeffects.dateType.now()
    ) -> O? {
        let obj = object(ofType: type, forPrimaryKey: primaryKey)
        if let date = obj?[keyPath: keyPath], date < now - within {
            return nil
        }
        return obj
    }

    func object<O: Object & LifetimeObject, Key: RawRepresentable>(
        of type: O.Type, for primaryKey: Key,
        _ keyPath: KeyPath<O, Date>,
        within: DateComponents,
        now: Date = coeffects.dateType.now()
    ) -> O? {
        return object(of: type, for: primaryKey.rawValue, keyPath, within: within, now: now)
    }

    func object<O: Object & LifetimeObject>(
        of type: O.Type,
        _ keyPath: KeyPath<O, Date>,
        within: DateComponents,
        now: Date = coeffects.dateType.now()
    ) -> O? {
        let obj = objects(type).first
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
        @objc override public class func primaryKey() -> String? { return "pk" }
        @objc dynamic private var pk = ""
        let list = List<Entity.History>()

        func count(for song: Entity.Song) -> Int {
            return list.filter("song._id = %@", song.id.rawValue).count
        }
    }
}
