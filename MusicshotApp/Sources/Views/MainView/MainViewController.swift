//
//  MainViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import RxCocoa
import UIKitSupport
import AutoLayoutSupport
import Compass

final class MainViewController: UITabBarController {
    private let customTabBar = TabBar()
    private var nav: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true

        viewControllers = [
            UINavigationController().apply { nav in
                self.nav = nav
                let vc = UIViewController()
                vc.view.backgroundColor = .white

                let test = UIView().apply {
                    $0.backgroundColor = .yellow
                }
                vc.view.addSubview(test)
                test.autolayout.apply {
                    $0.left.equal(to: vc.view)
                    $0.right.equal(to: vc.view)
                    $0.bottom.equal(to: vc.autolayout.safeArea.bottom)
                    $0.height.equal(to: 40)
                }
                test.addGestureRecognizer(UITapGestureRecognizer().apply {
                    $0.addTarget(self, action: #selector(pushView))
                })
                nav.viewControllers = [vc]
            }
        ]

        additionalSafeAreaInsets.bottom = 68 + 4
        view.addSubview(customTabBar)
        customTabBar.autolayout.apply {
            $0.left.equal(to: view.autolayout.left)
            $0.right.equal(to: view.autolayout.right)
            $0.bottom.equal(to: autolayout.safeArea.bottom, constant: additionalSafeAreaInsets.bottom)
        }
    }

    @objc
    private func pushView() {
        try? Navigator.navigate(urn: "search:初音 ミク")
//        let vc = UIViewController()
//        vc.view.backgroundColor = .blue
//
//        let test = UIView().apply {
//            $0.backgroundColor = .yellow
//        }
//        vc.view.addSubview(test)
//        test.autolayout.apply {
//            $0.left.equal(to: vc.view)
//            $0.right.equal(to: vc.view)
//            $0.bottom.equal(to: vc.autolayout.safeArea.bottom)
//            $0.height.equal(to: 40)
//        }
//        nav.pushViewController(vc, animated: true)
    }
}

// MARK: - private
private final class TabBar: UIView {
    private let contentView = UIView().apply { view in
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset.height = 2
        view.layer.shadowRadius = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        contentView.autolayout.apply {
            $0.top.equal(to: self)
            $0.left.equal(to: self, constant: 8)
            $0.right.equal(to: self, constant: -8)
            $0.bottom.equal(to: self, constant: -8)
            $0.height.equal(to: 60)
        }

        contentView.addMotionEffect(UIMotionEffectGroup().apply { group in
            let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            xMotion.minimumRelativeValue = -14
            xMotion.maximumRelativeValue = 14

            let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            yMotion.minimumRelativeValue = -28
            yMotion.maximumRelativeValue = 28

            group.motionEffects = [xMotion, yMotion]
        })

        contentView.addMotionEffect(UIMotionEffectGroup().apply { group in
            let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.width", type: .tiltAlongHorizontalAxis)
            xMotion.minimumRelativeValue = 14
            xMotion.maximumRelativeValue = -14

            let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.height", type: .tiltAlongVerticalAxis)
            yMotion.minimumRelativeValue = 28
            yMotion.maximumRelativeValue = -28

            group.motionEffects = [xMotion, yMotion]
        })

        contentView.addGestureRecognizer(UILongPressGestureRecognizer().apply {
            $0.minimumPressDuration = 0
            $0.addTarget(self, action: #selector(pressGesture))
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func pressGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
                    .translatedBy(x: 0, y: 1)
            })
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView.transform = .identity
            })
        default:
            break
        }
    }
}
