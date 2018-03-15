//
//  Routers.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import Compass

struct LoginRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {
        let vc = LoginViewController()
        vc.modalTransitionStyle = .crossDissolve
        currentController.present(vc, animated: true, completion: nil)
    }
}

struct MainRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {
        let present = {
            let vc = MainViewController()
            vc.modalTransitionStyle = .crossDissolve
            currentController.present(vc, animated: true, completion: nil)
        }
        if let presented = currentController.presentedViewController {
            presented.dismiss(animated: true, completion: present)
        } else {
            present()
        }
    }
}

struct StorefrontSelectRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {
        let vc = StorefrontSelectViewController()
        class Nav: UINavigationController {
            override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
        }
        let nav = Nav(rootViewController: vc).apply { nav in
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
        }
        top(currentController).present(nav, animated: true, completion: nil)
    }
}

struct ChartsRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {
        guard let from = currentController as? MainViewController else { return }
        let vc = ChartsViewController()
        from.present(vc, animated: true, completion: nil)
    }
}

struct SearchRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {
        let vc = SearchViewController()
        currentController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}
