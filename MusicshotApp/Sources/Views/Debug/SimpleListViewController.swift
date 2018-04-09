//
//  SimpleListViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/04/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import MusicshotCore
import UIKitSupport

class SimpleListViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().apply { layout in
            layout.sectionInset.bottom = 10
        }
        ).apply { _ in

    }

    let disposeBag = DisposeBag()

    private let numberOfSections: () -> Int
    private let numberOfItemsInSection: (_ section: Int) -> Int
    private let cellForItemAt: (_ cell: Cell, _ indexPath: IndexPath) -> Void
    private let didSelectItemAt: (_ indexPath: IndexPath) -> Void

    required init(
        numberOfSections: @escaping () -> Int,
        numberOfItemsInSection: @escaping (_ section: Int) -> Int,
        cellForItemAt: @escaping (_ cell: Cell, _ indexPath: IndexPath) -> Void,
        didSelectItemAt: @escaping (_ indexPath: IndexPath) -> Void
    ) {
        self.numberOfSections = numberOfSections
        self.numberOfItemsInSection = numberOfItemsInSection
        self.cellForItemAt = cellForItemAt
        self.didSelectItemAt = didSelectItemAt
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.register(Cell.self)

        view.addSubview(collectionView)
        collectionView.autolayout.edges.equal(to: view)
    }
}

extension SimpleListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as Cell
        cellForItemAt(cell, indexPath)
        return cell
    }
}

extension SimpleListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.width -= 16
        size.height = 60
        return size
    }
}

extension SimpleListViewController {
    final class Cell: UICollectionViewCell, Reusable {
        let imageView = UIImageView()
        let textLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.clipsToBounds = true
            contentView.backgroundColor = .white
            contentView.addSubview(imageView, textLabel)
            imageView.autolayout.left.equal(to: contentView)
            imageView.autolayout.centerY.equal(to: contentView)

            textLabel.autolayout.left.equal(to: imageView.autolayout.right, constant: 8)
            textLabel.autolayout.centerY.equal(to: contentView)

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.2
            layer.shadowOffset.height = 2
            layer.shadowRadius = 8
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
