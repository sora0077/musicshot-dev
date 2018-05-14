//
//  Repository+Search.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/14.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import SwiftDate
import AppleMusicKit

extension Repository {
    public final class Search {
        public func songs(with uniqueKey: String) -> Songs {
            return Songs(uniqueKey: uniqueKey)
        }

        public func hints(with uniqueKey: String) -> Hints {
            return Hints(uniqueKey: uniqueKey)
        }
    }
}

extension Repository.Search {
    public final class Hints {
        private let uniqueKey: String

        fileprivate init(uniqueKey: String) {
            self.uniqueKey = uniqueKey
        }

        public func list() throws -> List<String> {
            let realm = try Realm()
            if let hints = realm.object(of: Resource.Search.Hints.self, for: uniqueKey,
                                        \.createDate, within: 30.minutes) {
                return hints.items
            }
            try realm.write {
                realm.add(Resource.Search.Hints(uniqueKey: uniqueKey), update: true)
            }
            return try list()
        }

        public func fetch(term: String) -> Single<Void> {
            let uniqueKey = self.uniqueKey
            return Single<Bool>
                .just {
                    let realm = try Realm()
                    let hints = realm.object(of: Resource.Search.Hints.self, for: uniqueKey,
                                             \.updateDate, within: 60.minutes)
                    let fragment = realm.object(of: Resource.Search.Hints.Fragment.self, for: term,
                                                \.updateDate, within: 60.minutes)
                    if let hints = hints {
                        try realm.write {
                            hints.replace(fragment)
                        }
                    }
                    if term.isEmpty { return false }
                    return hints == nil || fragment == nil
                }
                .flatMap { fetch in
                    fetch
                        ? Single<GetSearchHints>
                            .storefront { storefront in
                                GetSearchHints(storefront: storefront.id, term: term)
                            }
                            .flatMap(MusicSession.shared.rx.send)
                            .do(onSuccess: { response in
                                let realm = try Realm()
                                try realm.write {
                                    let hints = realm.object(ofType: Resource.Search.Hints.self, forPrimaryKey: uniqueKey)
                                        ?? Resource.Search.Hints(uniqueKey: uniqueKey)
                                    let fragment = realm.object(ofType: Resource.Search.Hints.Fragment.self, forPrimaryKey: term)
                                        ?? Resource.Search.Hints.Fragment(term: term)
                                    hints.update(response, fragment)
                                    realm.add(fragment, update: true)
                                    realm.add(hints, update: true)
                                }
                            })
                            .map { _ in }
                        : .just(())
                }
        }
    }
}

extension Repository.Search {
        public final class Songs {
            private let uniqueKey: String

            fileprivate init(uniqueKey: String) {
                self.uniqueKey = uniqueKey
            }

            public func all(_ change: @escaping ListChange<Entity.Song>.Event) throws -> (Resource.Search.Songs, NotificationToken) {
                let realm = try Realm()
                if let songs = realm.object(of: Resource.Search.Songs.self, for: uniqueKey,
                                            \.createDate, within: 30.minutes) {
                    return (songs, songs.items.observe(change))
                }
                try realm.write {
                    realm.add(Resource.Search.Songs(uniqueKey: uniqueKey), update: true)
                }
                return try all(change)
            }

            public func `switch`(term: String) -> Single<Void> {
                let uniqueKey = self.uniqueKey
                return _currentState(term: term)
                    .flatMap { state in
                        switch state {
                        case .first: return fetchInitial(uniqueKey: uniqueKey, term: term, types: [.songs])
                        default: return .just(())
                        }
                    }
            }

            public func fetch(term: String) -> Single<Void> {
                let uniqueKey = self.uniqueKey
                return _currentState(term: term)
                    .flatMap { state -> Single<Void> in
                        switch state {
                        case .first: return fetchInitial(uniqueKey: uniqueKey, term: term, types: [.songs])
                        case .last: return .just(())
                        case .middle(let next, let songs): return MusicSession.shared.rx.send(next)
                            .do(onSuccess: { response in
                                let realm = try Realm()
                                guard let songs = realm.resolve(songs) else { return }
                                try realm.write {
                                    realm.add(response.data.compactMap { $0.attributes }, update: true)
                                    let fragment = realm.object(ofType: Resource.Search.SongsFragment.self, forPrimaryKey: term) ?? {
                                        Resource.Search.SongsFragment(term: term).apply {
                                            realm.add($0, update: true)
                                        }
                                    }()
                                    try fragment.update(response)
                                    try songs.update(response, fragment)
                                }
                            })
                            .catchError { error in
                                print(error)
                                throw error
                            }
                            .map { _ in }
                        }
                    }
            }

            private enum State {
                case first, last
                case middle(SearchResources.GetPage<Entity.Song>, Resource.Search.Songs.Ref)
            }
            private func _currentState(term: String) -> Single<State> {
                let uniqueKey = self.uniqueKey
                return Single<State>
                    .just {
                        let realm = try Realm()
                        let songs = realm.object(of: Resource.Search.Songs.self, for: uniqueKey,
                                                 \.updateDate, within: 60.minutes)
                        let fragment = realm.object(of: Resource.Search.SongsFragment.self, for: term,
                                                    \.updateDate, within: 60.minutes)
                        try realm.write {
                            songs?.replace(fragment)
                        }
                        if term.isEmpty { return .last }
                        switch (songs, fragment?.next) {
                        case (nil, _): return .first
                        case (let songs?, nil) where songs.items.isEmpty: return .first
                        case (let songs?, let next?): return .middle(try next.asRequest(), songs.ref)
                        case (_?, nil): return .last
                        }
                }
            }
        }
}

// MARK: - private
private func fetchInitial(uniqueKey: String, term: String, types: Set<ResourceType>) -> Single<Void> {
    return Single<SearchResources>
        .storefront { storefront in
            SearchResources(storefront: storefront.id, term: term, limit: 25, types: types)
        }
        .flatMap(MusicSession.shared.rx.send)
        .do(onSuccess: { response in
            let realm = try Realm()
            try realm.write {
                realm.add(response.songs?.data.compactMap { $0.attributes } ?? [], update: true)
                realm.add(response.albums?.data.compactMap { $0.attributes } ?? [], update: true)
                realm.add(response.musicVideos?.data.compactMap { $0.attributes } ?? [], update: true)

                if let fragment = try Resource.Search.SongsFragment(term: term, response.songs) {
                    realm.add(fragment, update: true)
                    realm.add(Resource.Search.Songs(uniqueKey: uniqueKey, fragment), update: true)
                }
            }
        })
        .map { _ in }
}
