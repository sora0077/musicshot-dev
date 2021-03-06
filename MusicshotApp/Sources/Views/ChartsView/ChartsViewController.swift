//
//  ChartsViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/08.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
import UIKitSupport
import MusicshotCore
import Constraint

private enum Section {
    case item
    case more
}

final class ChartsViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().apply { layout in
            layout.sectionInset.bottom = 10
        }
    ).apply { _ in

    }

    private let sections: [Section] = [.item, .more]

    private let repository = musicshot.repository.charts.songs()
    private var songs: List<Entity.Song>!
    private var token: NotificationToken!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.register(Cell.self, FetchCell.self)

        view.addSubview(collectionView)
        constrain(collectionView) { collectionView in
            collectionView.edge.equalTo(collectionView.superview.edge)
        }

        do {
            let (songs, token) = try repository.all { [weak self] changes in
                self?.collectionView.bind(changes, at: 0)
            }
            self.songs = songs
            self.token = token
        } catch {
            print(error)
        }
    }
}

extension ChartsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .item: return songs.count
        case .more: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .item:
            let item = songs[indexPath.row]
            let cell = collectionView.dequeueReusableCell(for: indexPath) as Cell
            cell.textLabel.text = item.name
            cell.imageView.image = nil
            Manager.shared.loadImage(
                with: item.artwork.url(for: 60 * UIScreen.main.scale),
                into: cell.imageView) { [weak imageView = cell.imageView] result, _ in
                    imageView?.image = result.value
                    imageView?.invalidateIntrinsicContentSize()
            }
            return cell
        case .more:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as FetchCell
            return cell
        }
    }
}

extension ChartsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .item:
            musicshot.player.insert(songs[indexPath.item])
        case .more:
            repository.fetch()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.width -= 16
        size.height = 60
        return size
    }
}

// MARK: - private
private final class Cell: UICollectionViewCell, Reusable {
    let imageView = UIImageView()
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        contentView.addSubview(imageView, textLabel)
        constrain(imageView, textLabel) { imageView, textLabel in
            imageView.left.equalTo(imageView.superview.left)
            imageView.centerY.equalTo(imageView.superview.centerY)

            textLabel.left.equalTo(imageView.right, constant: 8)
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

private final class FetchCell: UICollectionViewCell, Reusable {
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(textLabel)
        constrain(textLabel) { textLabel in
            textLabel.center.equalTo(textLabel.superview.center)
        }

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset.height = 2
        layer.shadowRadius = 8

        textLabel.text = "More"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
