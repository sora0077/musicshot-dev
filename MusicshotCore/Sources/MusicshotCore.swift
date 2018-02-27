//
//  MusicshotCore.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/02/27.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import Firebase
import Alamofire



public func helloworld() {
    print("hello world", FirebaseApp.configure(), SessionManager.default)
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    ref = db.collection("users").addDocument(data: [
        "first": "Ada",
        "last": "Lovelace",
        "born": 1815
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document added with ID: \(ref!.documentID)")
        }
    }
    Alamofire.request("https://www.google.co.jp")
        .responseString { (response) in
            print(response.result.value)
        }
    
}
