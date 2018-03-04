//
//  ViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SafariServices
import RxSwift

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        if musicshot.oauth.isLoggedIn {
//        } else {
            let gitHub = musicshot.oauth.gitHub()
            let vc = SFSafariViewController(url: gitHub.authorizeURL)
            vc.modalPresentationStyle = .popover

            gitHub.asSingle()
                .subscribe(
                    onSuccess: { [weak vc] in
                        vc?.dismiss(animated: true, completion: nil)
                    },
                    onError: { [weak vc] error in
                        vc?.dismiss(animated: true, completion: nil)
                    }
                )
                .disposed(by: disposeBag)
            DispatchQueue.main.async {
                self.present(vc, animated: true, completion: nil)
            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
