//
//  ReactiveX.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/03.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift
import DeepLinkKit
import Firebase
import FirebaseAuth
import APIKit

extension Reactive where Base: DPLDeepLinkRouter {
    func register(_ route: String) -> Observable<DPLDeepLink?> {
        return Observable.create({ [weak base] observer in
            base?.register(route) { link in
                observer.onNext(link)
            }
            return Disposables.create()
        })
    }
}

extension APIKit.Session: ReactiveCompatible {}
extension Reactive where Base: APIKit.Session {
    func send<Req: APIKit.Request>(_ request: Req) -> Single<Req.Response> {
        return Single.create(subscribe: { event in
            let task = self.base.send(request) { result in
                switch result {
                case .success(let response):
                    event(.success(response))
                case .failure(let error):
                    event(.error(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        })
    }
}

extension Reactive where Base: Auth {
    func signIn(with credential: AuthCredential) -> Single<User> {
        return Single.create { event in
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                switch (user, error) {
                case (_, let error?):
                    event(.error(error))
                case (let user?, _):
                    event(.success(user))
                default:
                    fatalError()
                }
            })
            return Disposables.create()
        }
    }
}

extension ObservableType {
    func timeout(_ duration: RxTimeInterval, scheduler: SchedulerType = MainScheduler.instance, _ value: @escaping () throws -> E) -> Observable<E> {
        return amb(Observable.just(())
            .delay(duration, scheduler: scheduler)
            .map(value))
    }
}
