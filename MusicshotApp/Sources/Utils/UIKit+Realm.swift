//
//  UIKit+Realm.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/12.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import RealmSwift

extension UITableView {
    func bind<C>(_ changes: RealmCollectionChange<C>, at section: Int) {
        switch changes {
        case .initial:
            reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            let indexPaths: ([Int]) -> [IndexPath] = {
                $0.map { IndexPath(item: $0, section: section) }
            }
            beginUpdates()
            insertRows(at: indexPaths(insertions), with: .automatic)
            deleteRows(at: indexPaths(deletions), with: .automatic)
            reloadRows(at: indexPaths(modifications), with: .automatic)
            endUpdates()
        case .error(let error):
            fatalError("\(error)")
        }
    }
}

extension UICollectionView {
    func bind<C>(_ changes: RealmCollectionChange<C>, at section: Int) {
        switch changes {
        case .initial:
            reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            let indexPaths: ([Int]) -> [IndexPath] = {
                $0.map { IndexPath(item: $0, section: section) }
            }
            performBatchUpdates({
                insertItems(at: indexPaths(insertions))
                deleteItems(at: indexPaths(deletions))
                reloadItems(at: indexPaths(modifications))
            }, completion: nil)
        case .error(let error):
            fatalError("\(error)")
        }
    }
}
