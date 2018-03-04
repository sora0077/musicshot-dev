//
//  OAuth.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FoundationSupport
import AppleMusicKit
import APIKit
import DeepLinkKit
import RxSwift
import Keys

public final class OAuth {
    public enum Error: Swift.Error {
        case timeout
        case unexpectedObject(Any, HTTPURLResponse)
    }

    private typealias Kind = (gitHub: Observable<(DPLDeepLink, code: String)>, Int)
    private let kind: Kind
    private let router = DPLDeepLinkRouter()
    private let scheme: String

    init(scheme: String) {
        self.scheme = scheme
        kind.gitHub = router.rx.register("\(scheme):///oauth/github")
            .flatMap { link -> Observable<(DPLDeepLink, code: String)> in
                if let link = link, let code = link.queryParameters["code"] as? String {
                    return Observable.just((link, code))
                } else {
                    return Observable.error(OAuth.Error.timeout)
                }
            }
            .timeout(10 * 60) { throw OAuth.Error.timeout }
        kind.1 = 0
    }

    public func handle(url: URL) -> Bool {
        return router.handle(url, withCompletion: nil)
    }
}

extension OAuth {
    public var isLoggedIn: Bool { return Auth.auth().currentUser != nil }

    public func signOut() throws {
        try Auth.auth().signOut()
    }
}

extension OAuth {
    public func gitHub() -> OAuth.GitHub {
        let redirectURL = URL(string: "\(scheme):///oauth/github")!
        let state = String.random()
        return OAuth.GitHub(redirectURL: redirectURL, state: state, observable: kind.gitHub
            .map { args in
                OAuth.GitHub.GetAccessToken(
                    clientId: env.githubClientId,
                    clientSecret: env.githubClientSecret,
                    code: args.code,
                    redirectURL: redirectURL,
                    state: state)
            }
            .flatMap {
                NetworkSession.shared.rx.send($0).asObservable()
            }
            .flatMap { response in
                Auth.auth().rx.signIn(with: GitHubAuthProvider.credential(withToken: response.accessToken))
                    .map { _ in }
                    .asObservable()
            }
            .take(1)
            .asSingle())
    }
}
