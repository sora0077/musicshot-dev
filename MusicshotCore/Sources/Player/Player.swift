//
//  Player.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa
import MusicshotPlayer

public final class Player {
    private let player = MusicshotPlayer.Player()

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
