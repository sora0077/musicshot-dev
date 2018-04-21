//
//  HistoryViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/04/21.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import MusicshotCore
import Nuke

final class HistoryViewController: SimpleListViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var token: NotificationToken?
    init() throws {
        weak var collectionView: UICollectionView?
        let (histories, token) = try musicshot.repository.history.all { change in
            collectionView?.bind(change, at: 0)
        }
        super.init(
            numberOfSections: {
                return 1
            },
            numberOfItemsInSection: { section in
                return histories.count
            },
            cellForItemAt: { cell, indexPath in
                let history = histories[indexPath.item]
                cell.textLabel.text = history.song?.name
                cell.imageView.image = nil
                if let song = history.song {
                    Manager.shared.loadImage(
                        with: song.artwork.url(for: 60 * UIScreen.main.scale),
                        into: cell.imageView) { [weak imageView = cell.imageView] result, _ in
                            imageView?.image = result.value
                            imageView?.invalidateIntrinsicContentSize()
                    }
                }
            },
            didSelectItemAt: { indexPath in
                if let song = histories[indexPath.item].song {
                    musicshot.player.insert(song)
                }
            })

        collectionView = self.collectionView
        self.token = token
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
