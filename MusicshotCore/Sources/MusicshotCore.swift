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
import AppleMusicKit
import RealmSwift
import Keys
@_exported import FoundationSupport
@_exported import RxSwift

let env = MusicshotKeys()

extension Realm {
    func add(_ object: Object?, update: Bool = true) {
        guard let object = object else { return }
        RealmSwift.Realm.add(self)(object, update: update)
    }
}

public func musicshotCore(oauthScheme: String) -> Core {
    return Core(oauthScheme: oauthScheme)
}

public final class Core {
    public let oauth: OAuth
    public let repository = Repository()
    private let disposeBag = DisposeBag()

    private let developerToken: Observable<String?>

    fileprivate init(oauthScheme: String) {
        FirebaseApp.configure()

        oauth = OAuth(scheme: oauthScheme)

        developerToken =  Auth.auth().rx.stateDidChange()
            .do(onNext: { (_, user) in
//                if let user = user {
//                    Firestore.firestore().collection("users").document(user.uid).setData([
//                        "lastAccessAt": FieldValue.serverTimestamp()
//                    ], options: .merge())
//                }
            })
            .flatMapLatest { (_, user) in
                user.map {
                    Firestore.firestore().collection("developerTokens").rx.document($0.uid)
                        .map { $0?.data()?["token"] as? String }
                } ?? .just(nil)
            }
            .share()

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
