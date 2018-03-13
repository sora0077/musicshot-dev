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

    private let queuePlayer = AVQueuePlayer()

    private let repository = musicshot.repository.charts.songs()
    private var songs: Resource.Charts.Songs!
    private var token: NotificationToken!
    private var statusObservation: NSKeyValueObservation?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.register(Cell.self, FetchCell.self)

        view.addSubview(collectionView)
        collectionView.autolayout.edges.equal(to: view)

        do {
            let (songs, token) = try repository.all { [weak self] changes in
                self?.collectionView.bind(changes, at: 0)
            }
            self.songs = songs
            self.token = token
        } catch {
            print(error)
        }

        #if (arch(i386) || arch(x86_64)) && os(iOS)
            queuePlayer.volume = 0.02
            print("simulator")
        #else
            print("iphone")
        #endif
        statusObservation = queuePlayer.observe(\.status) { (player, _) in
            if player.status == .readyToPlay {
                player.play()
            }
        }
    }
}

extension ChartsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .item: return songs.items.count
        case .more: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .item:
            let item = songs.items[indexPath.row]
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
            let preview = Repository.Preview(song: songs.items[indexPath.item])
            preview.fetch()
                .subscribe(onSuccess: { [weak self] url, _ in
                    self?.queuePlayer.insert(AVPlayerItem(url: url), after: nil)
                })
                .disposed(by: disposeBag)
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

private final class FetchCell: UICollectionViewCell, Reusable {
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(textLabel)
        textLabel.autolayout.center.equal(to: contentView)

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
