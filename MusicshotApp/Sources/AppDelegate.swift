//
//  AppDelegate.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import AVFoundation
import Compass
import MusicshotCore
import Compass
import WindowKit
import MusicshotUI

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

let player = Player()
let downloader = Downloader()

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
            "charts": ChartsRoute()
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

            if location.path.contains(in: searchRouter.routes.keys), let from = self?.manager[.search].rootViewController {
                searchRouter.navigate(to: location, from: from)
                return
            }

            if location.path.contains(in: mainRouter.routes.keys), let from = self?.manager[.main].rootViewController {
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
            fatalError()
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
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
