//
//  ViewController.swift
//  MusicshotApp
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        DispatchQueue.main.async {
            let vc = UIViewController()
            vc.view.backgroundColor = .blue
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
