//
//  Entity+Storefront.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import AppleMusicKit
import MusicshotUtility

extension String: Language {}

extension Entity {
    @objc(EntityStorefront)
    public final class Storefront: Object, AppleMusicKit.Storefront {
        public typealias Identifier = Tagged<Storefront, String>
        public typealias Language = String

        public var id: Identifier { return Tagged(rawValue: _id) }
        @objc private dynamic var _id: String = ""
        @objc public private(set) dynamic var defaultLanguageTag: Language = ""
        @objc public private(set) dynamic var name: String = ""
        public let supportedLanguageTags = List<String>()

        @objc override public class func primaryKey() -> String? { return "_id" }

        public convenience init(
            id: Entity.Storefront.Identifier,
            defaultLanguageTag: Entity.Storefront.Language,
            name: String,
            supportedLanguageTags: [Entity.Storefront.Language]
        ) throws {
            self.init()
            self._id = id.rawValue
            self.defaultLanguageTag = defaultLanguageTag
            self.name = name
            self.supportedLanguageTags.append(objectsIn: supportedLanguageTags)
        }
    }
}
