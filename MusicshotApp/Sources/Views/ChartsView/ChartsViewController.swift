//
//  ChartsViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/08.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import MusicshotCore

final class ChartsViewController: UIViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        musicshot.repository.charts.fetch()
            .subscribe(onSuccess: {  })
            .disposed(by: disposeBag)
    }
}
