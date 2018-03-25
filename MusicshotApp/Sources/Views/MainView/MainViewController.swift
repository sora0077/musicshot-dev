//
//  MainViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UIKitSupport
import AutoLayoutSupport
import Compass

final class MainViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private let customTabBar = TabBar()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "Background")

        let chartsButton = UIButton(type: .system).apply { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .ultraLight)
            button.setTitle("Charts", for: .normal)
            button.addTarget(self, action: #selector(chartsAction), for: .touchUpInside)
        }
        view.addSubview(chartsButton)
        chartsButton.autolayout.left.equal(to: view, constant: 8)
        chartsButton.autolayout.top.equal(to: view, constant: 120)

        let searchButton = UIButton(type: .system).apply { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .ultraLight)
            button.setTitle("Search", for: .normal)
            button.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        }
        view.addSubview(searchButton)
        searchButton.autolayout.left.equal(to: view, constant: 8)
        searchButton.autolayout.top.equal(to: chartsButton.autolayout.bottom, constant: 20)

        let rankingButton = UIButton(type: .system).apply { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .ultraLight)
            button.setTitle("Ranking Genres", for: .normal)
            button.addTarget(self, action: #selector(rankingAction), for: .touchUpInside)
        }
        view.addSubview(rankingButton)
        rankingButton.autolayout.left.equal(to: view, constant: 8)
        rankingButton.autolayout.top.equal(to: searchButton.autolayout.bottom, constant: 20)

        additionalSafeAreaInsets.bottom = 68 + 4
        view.addSubview(customTabBar)
        customTabBar.autolayout.apply {
            $0.left.equal(to: view.autolayout.left)
            $0.right.equal(to: view.autolayout.right)
            $0.bottom.equal(to: autolayout.safeArea.bottom, constant: additionalSafeAreaInsets.bottom)
        }

        do {
            if try musicshot.repository.storefronts.selected() == nil {
                rx.sentMessage(#selector(viewWillAppear))
                    .take(1)
                    .subscribeOn(MainScheduler.instance)
                    .subscribe(onNext: { _ in
                        try? Navigator.navigate(urn: "storefront/select")
                    })
                    .disposed(by: disposeBag)
            }
        } catch {
            print(error)
        }
    }

    @objc
    private func chartsAction() {
        try? Navigator.navigate(urn: "charts")
    }

    @objc
    private func searchAction() {
        try? Navigator.navigate(urn: "search")
    }

    @objc
    private func rankingAction() {
        try? Navigator.navigate(urn: "rankingGenres")
    }
}

// MARK: - private
private final class TabBar: UIView {
    private let contentView = UIView().apply { view in
        view.backgroundColor = UIColor(named: "Primary")?.withAlphaComponent(0.9)
        view.layer.cornerRadius = 20
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
