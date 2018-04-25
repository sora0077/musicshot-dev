//
//  AppDelegate.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Compass
import MusicshotCore
import Compass
import Nuke
import WindowKit
import MusicshotPlayer
import MusicshotUI
import MusicshotUtility

typealias DisposeBag = MusicshotUtility.DisposeBag

let musicshot = musicshotCore(oauthScheme: "musicshot-dev-oauth")

private func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func top(_ viewController: UIViewController) -> UIViewController {
    if let presented = viewController.presentedViewController {
        return top(presented)
    } else {
        return viewController
    }
}

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    enum WindowLevel: Int, WindowKit.WindowLevel {
        case main, search, login

        static var mainWindowLevel: AppDelegate.WindowLevel { return .main }
    }

    var window: UIWindow?
    private(set) lazy var manager = WindowKit.Manager<WindowLevel>(mainWindow: window!)

    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController().apply {
            $0.view.backgroundColor = UIColor(named: "Background")
        }
        window?.makeKeyAndVisible()
        window?.tintColor = UIColor(named: "Primary")

        setupWindows()
        setupRouting()
        setupMusicshot()
        setupAudio()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if musicshot.oauth.handle(url: url) {
            return true
        }
        do {
            try Navigator.navigate(url: url)
            return true
        } catch {}
        return false
    }

    private func presentMain() {
    }
}

extension AppDelegate {
    private func setupWindows() {
        UIViewController.swizzle_setNeedsStatusBarAppearanceUpdate()
        manager[.search].rootViewController = MainStatusBarStyleUpdaterViewController()
        manager[.login].rootViewController = MainStatusBarStyleViewController()
    }

    private func setupRouting() {
        Navigator.scheme = "musicshot-dev"

        var loginRouter = Router()
        loginRouter.routes = [
            "login": LoginRoute()
        ]

        var mainRouter = Router()
        mainRouter.routes = [
            "main": MainRoute()
        ]

        var postLoginRouter = Router()
        postLoginRouter.routes = [
            "storefront/select": StorefrontSelectRoute(),
            "charts": ChartsRoute(),
            "history": HistoryRoute(),
            "ranking/genres": RankingGenresRoute(),
            "ranking/genres:{genre}": RankingGenreRoute()
        ]

        var searchRouter = Router()
        searchRouter.routes = [
            "search": SearchRoute()
        ]

        Navigator.routes = Array(loginRouter.routes.keys)
            + Array(mainRouter.routes.keys)
            + Array(postLoginRouter.routes.keys)
            + Array(searchRouter.routes.keys)

        Navigator.handle = { [weak self] location in
            if location.path.contains(in: loginRouter.routes.keys), let from = self?.manager[.login].rootViewController {
                // SFSafariViewController only work in key window.
                self?.manager[.login].makeKey()
                loginRouter.navigate(to: location, from: from)
                return
            }
            guard musicshot.oauth.isLoggedIn else { return }

            if location.path.contains(in: postLoginRouter.routes.keys),
                let from = self?.manager[.main].rootViewController?.presentedViewController {
                postLoginRouter.navigate(to: location, from: from)
                return
            }

            if location.path.contains(in: searchRouter.routes.keys),
                let from = self?.manager[.search].rootViewController {
                searchRouter.navigate(to: location, from: from)
                return
            }

            if location.path.contains(in: mainRouter.routes.keys),
                let from = self?.manager[.main].rootViewController {
                self?.manager[.main].makeKey()
                mainRouter.navigate(to: location, from: from)
                return
            }
        }
    }

    private func setupMusicshot() {
        musicshot.oauth.rx.isLoggedIn
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { isLoggedIn in
                if isLoggedIn {
                    try? Navigator.navigate(urn: "main")
                } else {
                    try? Navigator.navigate(urn: "login")
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch {
            log.error(error)
            fatalError("\(error)")
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()

        final class NowPlayingInfo: PlayerMiddleware {
            private var nowPlayingInfo: [String: Any] = [:] {
                didSet {
                    DispatchQueue.main.async {
                        MPNowPlayingInfoCenter.default().nowPlayingInfo =
                            self.nowPlayingInfo.isEmpty ? nil : self.nowPlayingInfo
                    }
                }
            }
            private var artworkCancelSource = CancellationTokenSource()

            private let queue = DispatchQueue(label: "nowplayinginfo")
            private let disposeBag = DisposeBag()

            init() {
                musicshot.player.currentTimer
                    .distinctUntilChanged { Int($0) == Int($1) }
                    .subscribe(onNext: { [weak self] duration in
                        self?.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = duration
                    })
                    .disposed(by: disposeBag)
            }

            func playerDidChangeCurrentItem(_ item: PlayerItem?) throws {
                guard let songId = item?.userInfo as? Entity.Song.Identifier else {
                    nowPlayingInfo = [:]
                    return
                }

                guard let song = try musicshot.repository.songs.song(for: songId) else { return }

                nowPlayingInfo += [
                    "id": song.id,
                    MPMediaItemPropertyTitle: song.name,
                    MPMediaItemPropertyArtist: song.artistName,
                    MPMediaItemPropertyPlaybackDuration: song.preview.map { TimeInterval($0.duration / 1000) }
                ].compactValues()

                artworkCancelSource.cancel()
                artworkCancelSource = CancellationTokenSource()

                let size = CGSize(width: 60 * UIScreen.main.scale, height: 60 * UIScreen.main.scale)
                Nuke.Manager.shared.loadImage(
                    with: Request(url: song.artwork.url(for: size.width)),
                    token: artworkCancelSource.token,
                    completion: { [weak self] result in
                        guard self?.nowPlayingInfo["id"] as? Entity.Song.Identifier == songId else { return }
                        var info = self?.nowPlayingInfo ?? [:]
                        switch result {
                        case .success(let image):
                            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: size) { (size) in
                                print(#function, size)
                                return image
                            }

                        case .failure:
                            info[MPMediaItemPropertyArtwork] = nil
                        }
                        self?.nowPlayingInfo = info
                    })
            }
        }

        musicshot.player.install(middleware: NowPlayingInfo())
    }
}

//
// MARK: -
private extension UIViewController {
    static var swizzle_setNeedsStatusBarAppearanceUpdate: () -> Void = {
        let original = class_getInstanceMethod(
            UIViewController.self, #selector(UIViewController.setNeedsStatusBarAppearanceUpdate))
        let replaced = class_getInstanceMethod(
            UIViewController.self, #selector(UIViewController.swizzled_setNeedsStatusBarAppearanceUpdate))
        method_exchangeImplementations(original!, replaced!)
        return {}
    }()

    @objc
    func swizzled_setNeedsStatusBarAppearanceUpdate() {
        if let vc = appDelegate().manager[.login].rootViewController {
            vc.swizzled_setNeedsStatusBarAppearanceUpdate()
        } else {
            swizzled_setNeedsStatusBarAppearanceUpdate()
        }
    }
}

private final class MainStatusBarStyleViewController: UIViewController {
    private static func dig(_ vc: UIViewController) -> UIStatusBarStyle? {
        if vc.isBeingDismissed { return nil }
        if let vc = vc.presentedViewController, !vc.isBeingDismissed {
            return dig(vc)
        }
        return vc.preferredStatusBarStyle
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return appDelegate().manager[.login].rootViewController?.presentedViewController
            .flatMap(MainStatusBarStyleViewController.dig)
            ?? appDelegate().manager[.main].rootViewController?.presentedViewController
                .flatMap(MainStatusBarStyleViewController.dig)
            ?? .default
    }
}

private final class MainStatusBarStyleUpdaterViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setNeedsStatusBarAppearanceUpdate()
    }
}
