//
//  SongRepository.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift

public protocol SongRepository {

    func fetch(by ids: [Song.Identifier]) -> Single<Void>
}

extension SongRepository {

    public func fetch(by ids: Song.Identifier...) -> Single<Void> {
        return fetch(by: ids)
    }
}
