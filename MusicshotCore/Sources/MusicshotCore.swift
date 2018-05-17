//
//  MusicshotCore.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AVFoundation
import Firebase
import FirebaseAuth
import Fabric
import Crashlytics
import AppleMusicKit
import RealmSwift
import Keys
import MusicshotPlayer
import MusicshotUtility
@_exported import FoundationSupport
@_exported import RxSwift
@_exported import RealmSwift
@_exported import MusicshotEntity

let env = MusicshotKeys()

typealias DisposeBag = MusicshotUtility.DisposeBag

public let log = Logger()

public func musicshotCore(oauthScheme: String) -> Core {
    return Core(oauthScheme: oauthScheme)
}

extension Realm {
    func object<Element, KeyType>(
        ofType type: Element.Type, forPrimaryKey key: KeyType
    ) -> Element? where Element: RealmSwift.Object, KeyType: RawRepresentable {
        return object(ofType: type, forPrimaryKey: key.rawValue)
    }
}

public final class Core {
    public let oauth: OAuth

    public private(set) lazy var player = setupPlayer()
    public let repository = Repository()

    private let disposeBag = DisposeBag()

    private let developerToken: Observable<String?>

    fileprivate init(oauthScheme: String) {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        oauth = OAuth(scheme: oauthScheme)

        developerToken = Auth.auth().rx.stateDidChange()
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
            .do(onError: { error in
                log.error(error)
            })
            .share()

        developerToken
            .catchError { _ in .empty() }
            .subscribe(onNext: { developerToken in
                MusicSession.shared.authorization = {
                    if let token = developerToken {
                        return .init(developerToken: token)
                    } else {
                        return nil
                    }
                }()
            })
            .disposed(by: disposeBag)
    }

    private func setupPlayer() -> Player {
        let player = Player()
        return player
    }
}
