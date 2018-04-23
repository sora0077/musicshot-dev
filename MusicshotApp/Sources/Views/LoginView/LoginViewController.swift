//
//  LoginViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/03/05.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import SafariServices
import FontAwesome
import RxSwift
import Compass

final class LoginViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private let githubButton = UIButton().apply { button in
        button.setAttributedTitle(NSAttributedString([
            (String.fontAwesomeIcon(name: .github), [.font(UIFont.fontAwesome(ofSize: 100))])
            ]), for: .normal)

    }
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "Background")
        view.addSubview(githubButton)
        githubButton.autolayout.apply {
            $0.center.equal(to: view)
        }
        githubButton.addTarget(self, action: #selector(githubLoginAction), for: .touchUpInside)
    }

    @objc
    private func githubLoginAction() {
        let gitHub = musicshot.oauth.gitHub()
        let vc = SFSafariViewController(url: gitHub.authorizeURL)
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.preferredBarTintColor = UIColor(named: "Background")

        gitHub.asSingle()
            .subscribe(
                onSuccess: { [weak self] in
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                },
                onError: { [weak vc] _ in
                    vc?.dismiss(animated: true, completion: nil)
                }
            )
            .disposed(by: disposeBag)

        present(vc, animated: true, completion: nil)
    }
}

extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {

    }
}
