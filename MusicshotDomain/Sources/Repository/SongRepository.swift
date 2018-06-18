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

public protocol StorefrontRepository {

    func currentStorefront() throws -> Storefront?
    func saveCurrentStorefront(_ storefront: Storefront?) throws

    func allStorefronts() throws -> AnyLiveCollection<Storefront>

    func fetch(by ids: [Storefront.Identifier]) -> Single<Void>
    func fetchAll() -> Single<Void>
}
