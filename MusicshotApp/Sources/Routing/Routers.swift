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
        let vc = MainViewController()
        vc.modalTransitionStyle = .crossDissolve
        currentController.present(vc, animated: true, completion: nil)
    }
}

struct StorefrontSelectRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {
        let vc = StorefrontSelectViewController()
        let nav = UINavigationController(rootViewController: vc).apply { nav in
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
        }
        currentController.present(nav, animated: true, completion: nil)
    }
}

struct SearchRoute: Routable {
    func navigate(to location: Location, from currentController: CurrentController) throws {

    }
}
