//
//  Repository+Charts.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/11.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import AppleMusicKit

extension Repository {
    public final class Charts {
        public func songs(chart: String? = nil) -> Songs {
            return Songs(chart: chart)
        }

        public final class Songs {
            private let chart: String?

            fileprivate init(chart: String? = nil) {
                self.chart = chart
            }

            public func all(_ change: @escaping (ListChange<Entity.Song>) -> Void) throws -> (Resource.Charts.Songs, NotificationToken) {
                let realm = try Realm()
                if let songs = try Realm().object(ofType: Resource.Charts.Songs.self, forPrimaryKey: chart ?? "") {
                    return (songs, songs.items.observe(change))
                }
                try realm.write {
                    realm.add(Resource.Charts.Songs(chart: chart))
                }
                return try all(change)
            }

            public func fetch() -> Single<Void> {
                enum State {
                    case first, last, middle(GetCharts.GetPage<Entity.Song>, ThreadSafeReference<Resource.Charts.Songs>)
                }
                let chart = self.chart
                return Single<State>
                    .just {
                        let songs = try Realm().object(ofType: Resource.Charts.Songs.self, forPrimaryKey: chart ?? "")
                        switch (songs, songs?.next) {
                        case (nil, _): return .first
                        case (let songs?, nil) where songs.items.isEmpty: return .first
                        case (_?, nil): return .last
                        case (let songs?, let next?): return .middle(try next.asRequest(), .init(to: songs))
                        }
                    }
                    .flatMap { state -> Single<Void> in
                        switch state {
                        case .first: return fetchInitial(chart: chart, types: [.songs])
                        case .last: return .just(())
                        case .middle(let next, let songs): return MusicSession.shared.rx.send(next)
                            .do(onSuccess: { response in
                                let realm = try Realm()
                                guard let songs = realm.resolve(songs) else { return }
                                try realm.write {
                                    realm.add(response.data.compactMap { $0.attributes }, update: true)
                                    try songs.update(response)
                                }
                            })
                            .map { _ in }
                        }
                }
            }
        }
    }
}

// MARK: - private
private func fetchInitial(chart: String? = nil, types: Set<ResourceType>) -> Single<Void> {
    return Single<GetCharts>
        .just {
            guard let storefront = try Realm()
                .objects(InternalResource.SelectedStorefront.self)
                .first?.storefront else {
                    throw Repository.Error.storefrontNotReady
            }
            return GetCharts(storefront: storefront.id, types: types, chart: chart)
        }
        .flatMap(MusicSession.shared.rx.send)
        .do(onSuccess: { response in
            let realm = try Realm()
            try realm.write {
                realm.add(response.songs?.data.compactMap { $0.attributes } ?? [], update: true)
                realm.add(response.albums?.data.compactMap { $0.attributes } ?? [], update: true)
                realm.add(response.musicVideos?.data.compactMap { $0.attributes } ?? [], update: true)

                if let songs = try Resource.Charts.Songs(response.songs, isDefault: chart == nil) {
                    realm.add(songs, update: true)
                }
            }
        })
        .map { _ in }
}
