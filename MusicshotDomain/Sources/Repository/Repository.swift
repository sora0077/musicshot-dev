//
//  Repository.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

public struct Repository {
    public var song: SongRepository

    public init(
        song: SongRepository
    ) {
        self.song = song
    }
}

public var repository: Repository {
    return _repository
}

private var _repository: Repository!

public func setRepository(_ repo: Repository) {
    _repository = repo
}
