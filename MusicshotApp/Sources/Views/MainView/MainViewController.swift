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
import Constraint
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
        constrain(chartsButton) { chartsButton in
            chartsButton.left.equalTo(chartsButton.superview.left, constant: 8)
            chartsButton.top.equalTo(chartsButton.superview.top, constant: 120)
        }

        let searchButton = UIButton(type: .system).apply { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .ultraLight)
            button.setTitle("Search", for: .normal)
            button.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        }
        view.addSubview(searchButton)
        constrain(searchButton, chartsButton) { searchButton, chartsButton in
            searchButton.left.equalTo(searchButton.superview.left, constant: 8)
            searchButton.top.equalTo(chartsButton.bottom, constant: 20)
        }

        let rankingButton = UIButton(type: .system).apply { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .ultraLight)
            button.setTitle("Ranking Genres", for: .normal)
            button.addTarget(self, action: #selector(rankingAction), for: .touchUpInside)
        }
        view.addSubview(rankingButton)
        constrain(rankingButton, searchButton) { rankingButton, searchButton in
            rankingButton.left.equalTo(rankingButton.superview.left, constant: 8)
            rankingButton.top.equalTo(searchButton.bottom, constant: 20)
        }

        let historyButton = UIButton(type: .system).apply { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .ultraLight)
            button.setTitle("History", for: .normal)
            button.addTarget(self, action: #selector(historyAction), for: .touchUpInside)
        }
        view.addSubview(historyButton)
        constrain(historyButton, rankingButton) { historyButton, rankingButton in
            historyButton.left.equalTo(historyButton.superview.left, constant: 8)
            historyButton.top.equalTo(rankingButton.bottom, constant: 20)
        }

        additionalSafeAreaInsets.bottom = 68 + 4
        view.addSubview(customTabBar)
        constrain(customTabBar) { customTabBar in
            customTabBar.left.equalTo(customTabBar.superview.left)
            customTabBar.right.equalTo(customTabBar.superview.right)
            customTabBar.bottom.equalTo(customTabBar.superview.safeArea.bottom, constant: 20)
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

    @objc
    private func historyAction() {
        try? Navigator.navigate(urn: "history")
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
        constrain(contentView) { contentView in
            contentView.edge.equalTo(contentView.superview.edge,
                                     inset: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8))
            contentView.height.equalTo(60)
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
