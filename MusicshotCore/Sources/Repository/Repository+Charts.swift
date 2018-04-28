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
import SwiftDate
import AppleMusicKit

extension Repository {
    public final class Charts {
        public func songs(chart: String? = nil) -> Songs {
            return Songs(chart: chart)
        }

        public final class Songs {
            private let chart: String

            fileprivate init(chart: String? = nil) {
                self.chart = chart ?? ""
            }

            public func all(_ change: @escaping ListChange<Entity.Song>.Event) throws -> ListChange<Entity.Song>.CollectionAndToken {
                let realm = try Realm()
                if let songs = realm.object(of: Resource.Charts.Songs.self, for: chart,
                                            \.createDate, within: 30.minutes) {
                    return (songs.items, songs.items.observe(change))
                }
                try realm.write {
                    realm.add(Resource.Charts.Songs(chart: chart), update: true)
                }
                return try all(change)
            }

            public func fetch() -> Single<Void> {
                enum State {
                    case first, last, middle(GetCharts.GetPage<Entity.Song>, Resource.Charts.Songs.Ref)
                }
                let chart = self.chart
                return Single<State>
                    .just {
                        let songs = try Realm().object(of: Resource.Charts.Songs.self, for: chart,
                                                       \.updateDate, within: 60.minutes)
                        switch (songs, songs?.next) {
                        case (nil, _): return .first
                        case (let songs?, nil) where songs.items.isEmpty: return .first
                        case (let songs?, let next?): return .middle(try next.asRequest(), songs.ref)
                        case (_?, nil): return .last
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
        .storefront { storefront in
            GetCharts(storefront: storefront.id, types: types, chart: chart)
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
