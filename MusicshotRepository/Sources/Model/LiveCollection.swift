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

extension LiveCollection {
    static func from<C: RealmCollection>(_ collection: C) -> LiveCollection
        where Element: EntityConvertible, C.Element == Element.Impl.Storage {

        return LiveCollectionImpl(collection)
    }
}

private final class LiveCollectionImpl<Element>: LiveCollection<Element>
    where Element: EntityConvertible, Element.Impl.Storage: RealmCollectionValue {

    typealias Storage = Element.Impl.Storage

    class _Token: Token {
        private let notificationToken: NotificationToken

        init(_ token: NotificationToken) {
            notificationToken = token
            super.init()
        }

        deinit {
            notificationToken.invalidate()
        }
    }

    private let collection: AnyRealmCollection<Storage>

    init<C>(_ collection: C) where C: RealmCollection, C.Element == Storage {
        self.collection = AnyRealmCollection(collection)
        super.init()
    }

    override func observe(_ event: @escaping (Change) -> Void) -> Token {
        return _Token(
            collection.observe { change in
                event(Change(change))
            }
        )
    }

    override var startIndex: Int { return collection.startIndex }
    override var endIndex: Int { return collection.endIndex }

    override func index(after i: Int) -> Int { return collection.index(after: i) }

    override subscript (idx: Int) -> Element { return Element.Impl(storage: collection[idx]) as! Element }
}

private extension LiveCollection.Change {
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
