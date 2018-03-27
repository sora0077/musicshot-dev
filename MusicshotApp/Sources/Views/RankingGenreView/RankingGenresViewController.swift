//
//  RankingGenresViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/26.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import MusicshotCore
import UIKitSupport

final class RankingGenresViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().apply { layout in
            layout.sectionInset.bottom = 10
        }
    ).apply { _ in

    }

    private var genres: Results<Resource.Ranking.SelectedGenre>!
    private var token: NotificationToken!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.register(Cell.self)

        view.addSubview(collectionView)
        collectionView.autolayout.edges.equal(to: view)

        do {
            let (genres, token) = try musicshot.repository.ranking.genres.all { [weak self] changes in
                self?.collectionView.bind(changes, at: 0)
            }
            self.genres = genres
            self.token = token
        } catch {
            print(error)
        }

        DispatchQueue.main.async {
            musicshot.repository.ranking.genres.fetch()
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
}

extension RankingGenresViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = genres[indexPath.row]
        let cell = collectionView.dequeueReusableCell(for: indexPath) as Cell
        cell.textLabel.text = item.genre.name
        return cell
    }
}

extension RankingGenresViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
