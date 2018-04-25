//
//  RankingViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/04/25.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import MusicshotCore
import Nuke

final class RankingViewController: SimpleListViewController {
    private var token: NotificationToken?

    init(with id: Entity.Genre.Identifier) throws {
        let genre = musicshot.repository.ranking.genre(with: id)

        weak var collectionView: UICollectionView?
        let (songs, token) = try genre.all { changes in
            collectionView?.bind(changes, at: 0)
        }
        super.init(
            numberOfSections: {
                return 1
            },
            numberOfItemsInSection: { _ in
                return songs.count
            },
            cellForItemAt: { cell, indexPath in
                let item = songs[indexPath.row]
                cell.textLabel.text = item.name
                cell.imageView.image = nil
                Manager.shared.loadImage(
                    with: item.artwork.url(for: 60 * UIScreen.main.scale),
                    into: cell.imageView) { [weak imageView = cell.imageView] result, _ in
                        imageView?.image = result.value
                        imageView?.invalidateIntrinsicContentSize()
                }
            },
            didSelectItemAt: { indexPath in
                musicshot.player.insert(songs[indexPath.row])
            })

        collectionView = self.collectionView
        self.token = token

        genre.fetch()
            .subscribe(onError: { error in log.error(error) })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
