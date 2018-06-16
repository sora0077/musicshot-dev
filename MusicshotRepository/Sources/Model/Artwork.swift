//
//  Artwork.swift
//  MusicshotRepository
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import MusicshotDomain

extension Artwork {
    typealias Storage = ArtworkImpl.Storage
}

final class ArtworkImpl: Artwork {
    @objc(ArtworkStorage)
    final class Storage: RealmSwift.Object {
        override class func primaryKey() -> String? { return "url" }

        @objc dynamic var width: Int = -1
        @objc dynamic var height: Int = -1
        @objc dynamic var url: String = ""
        let bgColor = RealmOptional<Int>(nil)
        let textColor1 = RealmOptional<Int>(nil)
        let textColor2 = RealmOptional<Int>(nil)
        let textColor3 = RealmOptional<Int>(nil)
        let textColor4 = RealmOptional<Int>(nil)
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

    override var width: Int { return storage.width }
    override var height: Int { return storage.height }
    override var url: URL { return { URL(string: $0) }(storage.url)! }  // swiftlint:disable:this force_unwrapping
    override var bgColor: UIColor? { return storage.bgColor.value.flatMap { UIColor(hex: $0) } }
    override var textColor1: UIColor? { return storage.textColor1.value.flatMap { UIColor(hex: $0) } }
    override var textColor2: UIColor? { return storage.textColor2.value.flatMap { UIColor(hex: $0) } }
    override var textColor3: UIColor? { return storage.textColor3.value.flatMap { UIColor(hex: $0) } }
    override var textColor4: UIColor? { return storage.textColor4.value.flatMap { UIColor(hex: $0) } }
}
