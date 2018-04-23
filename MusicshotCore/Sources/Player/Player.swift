//
//  Player.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import RxSwift
import RxCocoa
import MusicshotPlayer
import MusicshotUtility

public final class Player {
    public var currentTimer: Observable<Double> { return player.currentTimer }
    private let player = MusicshotPlayer.Player()
    private let disposeBag = DisposeBag()

    init() {
        player.errors
            .subscribe(onNext: { error in
                log.error(error)
            })
            .disposed(by: disposeBag)

        install(middleware: InsertHistory())

        let center = MPRemoteCommandCenter.shared()
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.player.togglePlayPause()
            return .success
        }
        center.playCommand.addTarget { [weak self] _ in
            self?.player.play()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.player.pause()
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            if self?.player.nextTrack() ?? false {
                return .success
            }
            return .noSuchContent
        }
    }

    public func insert(_ song: Entity.Song) {
        let preview = Repository.Preview(song: song)
        let item = PlayerItem(fetcher: preview.fetch().map { url, _ in url })
        item.userInfo = song.id
        player.insert(item)
    }

    public func install(middleware: PlayerMiddleware) {
        player.install(middleware: middleware)
    }
}

//
// MARK: -
private final class InsertHistory: PlayerMiddleware {
    private let disposeBag = DisposeBag()
    private var willPlayingCount: [Entity.Song.Identifier: Int] = [:]
    private let downloadQueue = FIFOQueue<Void>(maxConcurrentOperationCount: 1)

    func playerDidCreateItem(_ item: PlayerItem) throws {
        guard let songId = item.userInfo as? Entity.Song.Identifier else { return }
        willPlayingCount[songId, default: 0] += 1

        if willPlayingCount[songId, default: 0] >= 6 {
            let realm = try Realm()
            guard let song = realm.object(ofType: Entity.Song.self, forPrimaryKey: songId) else { return }
            downloadQueue.append(Repository.Preview(song: song).download())
        }
    }

    func playerDidEndPlayToEndTime(_ item: PlayerItem) throws {
        guard let songId = item.userInfo as? Entity.Song.Identifier else { return }
        let realm = try Realm()
        guard let histories = realm.objects(InternalResource.Histories.self).first else {
            try realm.write {
                realm.add(InternalResource.Histories(), update: true)
            }
            try playerDidEndPlayToEndTime(item)
            return
        }
        guard let song = realm.object(ofType: Entity.Song.self, forPrimaryKey: songId) else { return }
        try realm.write {
            histories.list.append(Entity.History(song))
        }
        if histories.count(for: song) >= 3 {
            downloadQueue.append(Repository.Preview(song: song).download())
        }
    }
}
