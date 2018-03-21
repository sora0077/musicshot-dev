//
//  ReactiveX.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/21.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift
import DeepLinkKit
import Firebase
import FirebaseAuth
import APIKit
import AppleMusicKit

extension Reactive where Base: DPLDeepLinkRouter {
    public func register(_ route: String) -> Observable<DPLDeepLink?> {
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
    public func send<Req: APIKit.Request>(_ request: Req) -> Single<Req.Response> {
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

extension Reactive where Base: AppleMusicKit.Session {
    public func send<Req: AppleMusicKit.Request>(_ request: Req) -> Single<Req.Response> {
        return Single.create(subscribe: { event in
            let task = self.base.send(request) { result in
                switch result {
                case .success(let response):
                    event(.success(response))
                case .failure(let error):
                    print(error)
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
    public func signIn(with credential: AuthCredential) -> Single<User> {
        return Single.create { event in
            self.base.signIn(with: credential, completion: { (user, error) in
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

    public func stateDidChange() -> Observable<(Auth, User?)> {
        return Observable.create { observer in
            let handle = self.base.addStateDidChangeListener { (auth, user) in
                observer.onNext((auth, user))
            }
            return Disposables.create {
                self.base.removeStateDidChangeListener(handle)
            }
        }
    }
}

extension Reactive where Base: CollectionReference {
    public func document(_ path: String) -> Observable<DocumentSnapshot?> {
        return Observable.create { observer in
            let listener = self.base.document(path).addSnapshotListener { (snapshot, error) in
                switch (snapshot, error) {
                case (_, let error?):
                    observer.onError(error)
                case (let snapshot, _):
                    observer.onNext(snapshot)
                }
            }
            return Disposables.create {
                listener.remove()
            }
        }
    }
}
