//
//  ReactiveX.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/03.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    public func timeout(_ duration: RxTimeInterval, scheduler: SchedulerType = MainScheduler.instance, _ value: @escaping () throws -> E) -> Observable<E> {
        return amb(Observable.just(())
            .delay(duration, scheduler: scheduler)
            .map(value))
    }

    public func compactMap<T>(_ transform: @escaping (E) throws -> T?) -> Observable<T> {
        return flatMap {
            try transform($0).map(Observable.just) ?? .empty()
        }
    }

    public func compact<T>() -> Observable<T> where E == T? {
        return compactMap { $0 }
    }
}

extension Single {
    public static func just(_ body: () throws -> E) -> Single<E> {
        do {
            return .just(try body())
        } catch {
            return .error(error)
        }
    }
}

extension Reactive where Base: NSObject {
    public func observe<E>(
        _ keyPath: KeyPath<Base, E>,
        options: NSKeyValueObservingOptions = []
    ) -> Observable<(Base, E, NSKeyValueObservedChange<E>)> {
        return Observable.create({ observer in
            var token = self.base.observe(keyPath, options: options, changeHandler: { (base, change) in
                observer.onNext((base, base[keyPath: keyPath], change))
            }) as NSKeyValueObservation?
            return Disposables.create {
                token?.invalidate()
                token = nil
            }
        })
    }
}
