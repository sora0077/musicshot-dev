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

let musicshot = musicshotCore(oauthScheme: "musicshot-dev-oauth")

private var postLoginRouter = Router()

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    enum WindowLevel: Int, WindowKit.WindowLevel {
        case main, search, login

        static var mainWindowLevel: AppDelegate.WindowLevel { return .main }
    }

    var window: UIWindow?
    private(set) lazy var manager = Manager<WindowLevel>(mainWindow: window!)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        setupWindows()
        setupRouting()
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
}

extension AppDelegate {
    private func setupWindows() {
        manager[.search].rootViewController = UIViewController()
        manager[.login].rootViewController = UIViewController()
    }

    private func setupRouting() {
        Navigator.scheme = "musicshot-dev"

        postLoginRouter.routes = [
            "search:{term}": SearchRoute()
        ]

        Navigator.routes = Array(postLoginRouter.routes.keys)

        Navigator.handle = { [weak self] location in

        }
    }
}
