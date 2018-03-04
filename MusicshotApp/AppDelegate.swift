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

let musicshot = musicshotCore(oauthScheme: "musicshot-dev-oauth://")

private var postLoginRouter = Router()

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

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
    private func setupRouting() {
        Navigator.scheme = "musicshot-dev"

        Navigator.routes = Array(postLoginRouter.routes.keys)
    }
}
