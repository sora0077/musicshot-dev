//
//  LiveCollection.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/18.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import MusicshotDomain
import RealmSwift

extension AnyLiveCollection {
    convenience init<C: RealmCollection>(_ collection: C)
        where Element: EntityConvertible, C.Element == Element.Impl.Storage {

        self.init(LiveCollectionImpl(collection))
    }
}

final class LiveCollectionImpl<Element>: LiveCollection
    where Element: EntityConvertible, Element.Impl.Storage: RealmCollectionValue {

    typealias Storage = Element.Impl.Storage

    private final class Token: LiveCollectionToken {
        private let notificationToken: NotificationToken

        init(_ token: NotificationToken) {
            notificationToken = token
        }

        deinit {
            notificationToken.invalidate()
        }
    }

    private let collection: AnyRealmCollection<Storage>

    init<C>(_ collection: C) where C: RealmCollection, C.Element == Storage {
        self.collection = AnyRealmCollection(collection)
    }

    func observe(_ event: @escaping (LiveCollectionChange) -> Void) -> LiveCollectionToken {
        return Token(
            collection.observe { change in
                event(LiveCollectionChange(change))
            }
        )
    }

    var startIndex: Int { return collection.startIndex }
    var endIndex: Int { return collection.endIndex }

    func index(after i: Int) -> Int { return collection.index(after: i) }

    subscript (idx: Int) -> Element { return Element.Impl(storage: collection[idx]) as! Element }
}

private extension LiveCollectionChange {
    init<T>(_ change: RealmCollectionChange<T>) where T: RealmCollection {
        switch change {
        case .initial:
            self = .initial

        case .update(_, let deletions, let insertions, let modifications):
            self = .update(deletions: deletions, insertions: insertions, modifications: modifications)

        case .error(let error):
            self = .error(error)
        }
    }
}
