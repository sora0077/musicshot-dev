//
//  Timeline+Realm.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/05/08.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift

protocol _RealmTimeline: Timeline {
    associatedtype Collection: RealmCollection where Collection.Element == Element, Collection.Index == Int

    var _items: Collection { get }
}

extension _RealmTimeline {
    public var count: Int { return _items.count }

    public subscript (idx: Int) -> Element { return _items[idx] }
}
