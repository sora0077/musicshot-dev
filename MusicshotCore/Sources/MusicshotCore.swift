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
import AppleMusicKit
import RealmSwift
import Keys
import MusicshotPlayer
import MusicshotUtility
@_exported import FoundationSupport
@_exported import RxSwift

let env = MusicshotKeys()

typealias DisposeBag = MusicshotUtility.DisposeBag

public func musicshotCore(oauthScheme: String) -> Core {
    return Core(oauthScheme: oauthScheme)
}

public final class Core {
    public let oauth: OAuth

    public private(set) lazy var player = setupPlayer()
    public let repository = Repository()

    private let disposeBag = DisposeBag()

    private let developerToken: Observable<String?>

    fileprivate init(oauthScheme: String) {
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

    private func setupPlayer() -> Player {
        let player = Player()

        class InsertHistory: PlayerMiddleware {
            func playerDidEndPlayToEndTime(_ item: AVPlayerItem) {
                guard let songId = item.songId else { return }
                do {
                    let realm = try Realm()
                    guard let histories = realm.objects(InternalResource.Histories.self).first else { return }
                    guard let song = realm.object(ofType: Entity.Song.self, forPrimaryKey: songId) else { return }
                    try realm.write {
                        histories.list.append(Entity.History(song))
                    }
                } catch {
                    print(#function, error)
                }
            }
        }
        player.install(middleware: InsertHistory())
        return player
    }
}
