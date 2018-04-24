//
//  StorefrontSelectViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/06.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import MusicshotCore
import UIKitSupport
import Constraint

final class StorefrontSelectViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().apply { _ in

        }
    ).apply { _ in

    }

    private var storefronts: List<Entity.Storefront>!
    private var token: NotificationToken!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.register(Cell.self)

        view.addSubview(collectionView)
        constrain(collectionView) { collectionView in
            collectionView.edge.equalTo(collectionView.superview.edge)
        }

        do {
            let (storefronts, token) = try musicshot.repository.storefronts.all { [weak self] changes in
                self?.collectionView.bind(changes, at: 0)
            }
            self.storefronts = storefronts
            self.token = token
        } catch {
            print(error)
        }

        musicshot.repository.storefronts.fetch()
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension StorefrontSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storefronts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as Cell
        cell.textLabel.text = storefronts[indexPath.row].name
        return cell
    }
}

extension StorefrontSelectViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.width -= 16
        size.height = 60
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            try musicshot.repository.storefronts.select(storefronts[indexPath.row])
            dismiss(animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
}

// MARK: - private
private final class Cell: UICollectionViewCell, Reusable {
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(textLabel)
        constrain(textLabel) { textLabel in
            textLabel.left.equalTo(textLabel.superview.right, constant: 8)
            textLabel.centerY.equalTo(textLabel.superview.centerY)
        }

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset.height = 2
        layer.shadowRadius = 8
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
