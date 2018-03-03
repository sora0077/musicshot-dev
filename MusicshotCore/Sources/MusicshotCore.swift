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
import RxSwift
import Keys

let env = MusicshotKeys()

public final class Core {
    public let oauth: OAuth
    private let disposeBag = DisposeBag()

    private let developerToken: Observable<String?>

    public init(oauthScheme: String) {
        FirebaseApp.configure()

        oauth = OAuth(scheme: oauthScheme)

        developerToken =  Auth.auth().rx.stateDidChange()
            .do(onNext: { (_, user) in
                if let user = user {
                    Firestore.firestore().collection("users").document(user.uid).setData([
                        "lastAccessAt": FieldValue.serverTimestamp()
                    ], options: .merge())
                }
            })
            .flatMapLatest { (_, user) in
                user.map {
                    Firestore.firestore().collection("developerTokens").rx.document($0.uid)
                        .map { $0?.data()?["token"] as? String }
                } ?? .just(nil)
            }

        developerToken
            .catchError { _ in .empty() }
            .subscribe(onNext: { developerToken in
                MusicSession.shared.authorization = developerToken.map {
                    Authorization(developerToken: $0)
                }
            })
            .disposed(by: disposeBag)
    }
}
