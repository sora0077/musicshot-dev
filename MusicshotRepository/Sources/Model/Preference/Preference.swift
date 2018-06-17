//
//  Preference.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/17.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift

@objc(Preference)
final class Preference: RealmSwift.Object {
    override class func primaryKey() -> String? { return "pk" }

    static var pkValue: String { return "pk" }

    @objc private dynamic var pk = "pk"
    @objc dynamic var storefront: StorefrontImpl.Storage?
}
