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

extension String: Language {}

extension Entity {
    @objc(Storefront)
    public final class Storefront: Object, AppleMusicKit.Storefront {
        public typealias Identifier = String
        public typealias Language = String

        @objc public private(set) dynamic var id: Identifier = ""
        @objc public private(set) dynamic var defaultLanguageTag: Language = ""
        @objc public private(set) dynamic var name: String = ""
        public let supportedLanguageTags = List<String>()

        @objc override public class func primaryKey() -> String? { return "id" }

        public convenience init(
            id: Entity.Storefront.Identifier,
            defaultLanguageTag: Entity.Storefront.Language,
            name: String,
            supportedLanguageTags: [Entity.Storefront.Language]
        ) throws {
            self.init()
            self.id = id
            self.defaultLanguageTag = defaultLanguageTag
            self.name = name
            self.supportedLanguageTags.append(objectsIn: supportedLanguageTags)
        }
    }
}
