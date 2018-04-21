//
//  Repository+History.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/22.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

extension Repository {
    public final class History {
        init() {}

        public func all(ascending: Bool = false, _ change: @escaping ResultsChange<Entity.History>.Event) throws -> ResultsChange<Entity.History>.CollectionAndToken {
            let realm = try Realm()
            if let holder = realm.objects(InternalResource.Histories.self).first {
                let list = holder.list.sorted(byKeyPath: "createDate", ascending: ascending)
                return (list, list.observe(change))
            }
            try realm.write {
                realm.add(InternalResource.Histories())
            }
            return try all(change)
        }
    }
}
