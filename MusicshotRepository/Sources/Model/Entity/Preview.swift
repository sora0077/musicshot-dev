//
//  Preview.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Preview {
    typealias Storage = PreviewImpl.Storage
}

final class PreviewImpl: Preview {
    @objc(PreviewStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "url" }

        @objc dynamic var url: String = ""
        @objc dynamic var artwork: ArtworkImpl.Storage!
    }

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
        super.init()
    }

    convenience init?(storage: Storage?) {
        guard let storage = storage else { return nil }
        self.init(storage: storage)
    }

    override var url: URL { return { URL(string: $0) }(storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var artwork: Artwork? { return ArtworkImpl(storage: storage.artwork) }
}
