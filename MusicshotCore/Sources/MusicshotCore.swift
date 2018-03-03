//
//  MusicshotCore.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FoundationSupport
import AppleMusicKit
import class APIKit.Session
import protocol APIKit.Request
import DeepLinkKit
import RxSwift
import Keys

let env = MusicshotKeys()

public final class Core {
    private let session: (music: APIKit.Session, network: APIKit.Session) = (MusicSession.shared, NetworkSession.shared)
    private let router = DPLDeepLinkRouter()

    typealias OAuthKind = (gitHub: Observable<(DPLDeepLink, code: String)>, Int)
    private let oauth: OAuthKind
    private let disposeBag = DisposeBag()

    public init() {
        FirebaseApp.configure()

        oauth.gitHub = router.rx.register("/oauth/github")
            .flatMap { link -> Observable<(DPLDeepLink, code: String)> in
                if let link = link, let code = link.queryParameters["code"] as? String {
                    return Observable.just((link, code))
                } else {
                    return Observable.error(OAuth.Error.timeout)
                }
            }
            .timeout(10 * 60) { throw OAuth.Error.timeout }
        oauth.1 = 0

        Auth.auth().rx.stateDidChange()
            .do(onNext: { (_, user) in
                if let user = user {
                    Firestore.firestore().collection("users").document(user.uid).setData([
                        "lastAccessAt": FieldValue.serverTimestamp()
                    ], options: .merge())
                }
            })
            .map { $1 }
            .flatMapLatest { user in
                user.map {
                    Firestore.firestore().collection("developerTokens").rx.document($0.uid)
                        .map { $0?.data()?["token"] as? String }
                } ?? .just(nil)
            }
            .catchError { _ in .empty() }
            .subscribe(onNext: { [weak self] developerToken in
                (self?.session.music as? AppleMusicKit.Session)?.authorization = developerToken.map {
                    Authorization(developerToken: $0)
                }
            })
            .disposed(by: disposeBag)
    }

    public func handle(url: URL) -> Bool {
        return router.handle(url, withCompletion: nil)
    }
}

extension Core {
    public var isLoggedIn: Bool { return Auth.auth().currentUser != nil }

    public func signOut() throws {
        try Auth.auth().signOut()
    }

    public func gitHub(withAppScheme scheme: String) -> OAuth.GitHub {
        let redirectURL = URL(string: "\(scheme)/oauth/github")!
        let state = String.random()
        return OAuth.GitHub(redirectURL: redirectURL, state: state, observable: oauth.gitHub
            .map { args in
                OAuth.GitHub.GetAccessToken(
                    clientId: env.githubClientId,
                    clientSecret: env.githubClientSecret,
                    code: args.code,
                    redirectURL: redirectURL,
                    state: state)
            }
            .flatMap { [weak self] in
                self?.session.network.rx.send($0).asObservable() ?? .empty()
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
