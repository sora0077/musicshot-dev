//
//  DisposeBag.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/20.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

public final class DisposeBag {
    fileprivate lazy var bag: RxSwift.DisposeBag? = .init()
    fileprivate lazy var observations: [NSKeyValueObservation] = []
    fileprivate lazy var tokens: [NotificationToken] = []

    public init() {}

    deinit {
        bag = nil
        observations.removeAll()
        tokens.removeAll()
    }
}

public extension Disposable {
    func disposed(by bag: DisposeBag?) {
        if let bag = bag?.bag {
            disposed(by: bag)
        }
    }
}

public extension NSKeyValueObservation {
    func disposed(by bag: DisposeBag?) {
        bag?.observations.append(self)
    }
}

public extension NotificationToken {
    func disposed(by bag: DisposeBag?) {
        bag?.tokens.append(self)
    }
}
