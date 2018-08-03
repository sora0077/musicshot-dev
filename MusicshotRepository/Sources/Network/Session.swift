//
//  Session.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import APIKit
import Alamofire
import AppleMusicKit
import MusicshotUtility

final class MusicSession: AppleMusicKit.Session {
    open override class var shared: MusicSession { return _shared }
    private static let _shared = MusicSession(adapter: AlamofireAdapter())

    override init(adapter: SessionAdapter, callbackQueue: CallbackQueue = .main) {
        super.init(adapter: adapter, callbackQueue: callbackQueue)

        authorization = Authorization(developerToken: """
        eyJraWQiOiI3Vlk1UlQ0MjMzIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJCMlRENTRVNE1BIiwiaWF0IjoxNTI5NDE3MjI2LjU5MTg5NCwiZXhwIjoxNTQ1MTg3MjI2LjU5MTg5NX0.jUKQSuQwIX7i-TJ2fHKqIVdGoNFOIE4xYIYiQoiLUdCJZCqozUYi__ZZKfykEgmW-21Q0585GTOArzRb6P5YKg
        """)
    }
}

final class NetworkSession: APIKitSession {
    open override class var shared: NetworkSession { return _shared }
    private static let _shared = NetworkSession(adapter: AlamofireAdapter())
}

// MARK: -
extension DataRequest: SessionTask {}

private final class AlamofireAdapter: SessionAdapter {
    private let manager = SessionManager.default

    func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask {
        let request = manager.request(URLRequest)
        request.responseData(completionHandler: { response in
            handler(response.data, response.response, response.error)
        })
        #if DEBUG
        print(request.debugDescription)
        #endif
        return request
    }

    func getTasks(with handler: @escaping ([SessionTask]) -> Void) {
        manager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let allTasks = dataTasks as [URLSessionTask]
                + uploadTasks as [URLSessionTask]
                + downloadTasks as [URLSessionTask]
            handler(allTasks.map { $0 })
        }
    }
}

import RxSwift

extension APIKit.Session: ReactiveCompatible {}

extension Reactive where Base: MusicSession {
    static func response<Req: AppleMusicKit.Request>(from request: Req) -> Single<Req.Response> {
        return Single.create(subscribe: { event in
            var token = Base.send(request, handler: { result in
                switch result {
                case .success(let response):
                    event(.success(response))

                case .failure(let error):
                    event(.error(error))
                }
            })
            return Disposables.create {
                token?.cancel()
                token = nil
            }
        })
    }
}

extension Reactive where Base: NetworkSession {
    static func response<Req: APIKit.Request>(from request: Req) -> Single<Req.Response> {
        return Single.create(subscribe: { event in
            var token = Base.send(request, handler: { result in
                switch result {
                case .success(let response):
                    event(.success(response))

                case .failure(let error):
                    event(.error(error))
                }
            })
            return Disposables.create {
                token?.cancel()
                token = nil
            }
        })
    }
}
