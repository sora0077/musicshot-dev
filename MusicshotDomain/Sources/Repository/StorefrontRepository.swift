//
//  StorefrontRepository.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/20.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift

public protocol StorefrontRepository {

    func currentStorefront() throws -> Storefront?
    func saveCurrentStorefront(_ storefront: Storefront?) throws

    func allStorefronts() throws -> LiveCollection<Storefront>

    func fetch(by ids: [Storefront.Identifier]) -> Single<Void>
    func fetchAll() -> Single<Void>
}

extension StorefrontRepository {

    public func fetch(by ids: Storefront.Identifier...) -> Single<Void> {
        return fetch(by: ids)
    }
}
