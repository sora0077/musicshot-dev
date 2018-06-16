//
//  Storefront.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Storefront: Entity {
    public typealias Identifier = Tagged<Storefront, String>

    /// Persistent identifier of the resource. This member is required.
    public let id: Identifier

    public init(id: Identifier) {
        self.id = id
    }

    /// The localized name of the storefront.
    open var name: String { fatalError("abstract") }
    /// The localizations that the storefront supports, represented as an array of language tags.
    open var supportedLanguageTags: [String] { fatalError("abstract") }
    /// The default language for the storefront, represented as a language tag.
    open var defaultLanguageTag: String { fatalError("abstract") }
}
