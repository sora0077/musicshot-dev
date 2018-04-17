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

public final class Player {
    public var currentTimer: Observable<Double> { return player.currentTimer }
    private let player = MusicshotPlayer.Player()

    init() {
        let center = MPRemoteCommandCenter.shared()
        center.togglePlayPauseCommand.addTarget { [weak self] event in
            self?.player.togglePlayPause()
            return .success
        }
        center.playCommand.addTarget { [weak self] event in
            self?.player.play()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] event in
            self?.player.pause()
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] event in
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
