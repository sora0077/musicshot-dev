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

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.register(Cell.self)

        view.addSubview(collectionView)
        collectionView.autolayout.edges.equal(to: view)

        let (storefronts, token) = musicshot.repository.storefronts.all { [weak self] changes in
            guard let collectionView = self?.collectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                let indexPaths: ([Int]) -> [IndexPath] = {
                    $0.map { IndexPath(item: $0, section: 0) }
                }
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: indexPaths(insertions))
                    collectionView.deleteItems(at: indexPaths(deletions))
                    collectionView.reloadItems(at: indexPaths(modifications))
                }, completion: nil)
            case .error(let error):
                fatalError("\(error)")
            }
        }
        self.storefronts = storefronts
        self.token = token
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
        musicshot.repository.storefronts.select(storefronts[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - private
private final class Cell: UICollectionViewCell, Reusable {
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(textLabel)
        textLabel.autolayout.centerY.equal(to: contentView)
        textLabel.autolayout.left.equal(to: contentView, constant: 8)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset.height = 2
        layer.shadowRadius = 8
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
