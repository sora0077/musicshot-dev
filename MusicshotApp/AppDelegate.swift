//
//  AppDelegate.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import Compass
import MusicshotCore
import Compass
import WindowKit
import MusicshotUI

let musicshot = musicshotCore(oauthScheme: "musicshot-dev-oauth")

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    enum WindowLevel: Int, WindowKit.WindowLevel {
        case main, search, login

        static var mainWindowLevel: AppDelegate.WindowLevel { return .main }
    }

    var window: UIWindow?
    private(set) lazy var manager = Manager<WindowLevel>(mainWindow: window!)

    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController().apply {
            $0.view.backgroundColor = UIColor(named: "Background")
        }
        window?.makeKeyAndVisible()

        setupWindows()
        setupRouting()
        setupMusicshot()
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
        manager[.search].rootViewController = UIViewController()
        manager[.login].rootViewController = UIViewController()
    }

    private func setupRouting() {
        Navigator.scheme = "musicshot-dev"

        var preLoginRouter = Router()
        preLoginRouter.routes = [
            "login": LoginRoute()
        ]

        var postLoginRouter = Router()
        postLoginRouter.routes = [
            "main": MainRoute(),
            "search:{term}": SearchRoute()
        ]

        Navigator.routes = Array(preLoginRouter.routes.keys)
            + Array(postLoginRouter.routes.keys)

        Navigator.handle = { [weak self] location in
            if location.path.contains(in: preLoginRouter.routes.keys), let from = self?.manager[.login].rootViewController {
                self?.manager[.login].makeKey()
                preLoginRouter.navigate(to: location, from: from)
                return
            }
            guard musicshot.oauth.isLoggedIn else { return }

            if location.path.contains(in: postLoginRouter.routes.keys), let from = self?.manager[.main].rootViewController {
                self?.manager[.main].makeKey()
                if let presented = from.presentedViewController {
                    presented.dismiss(animated: true, completion: {
                        postLoginRouter.navigate(to: location, from: from)
                    })
                } else {
                    postLoginRouter.navigate(to: location, from: from)
                }
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
}
