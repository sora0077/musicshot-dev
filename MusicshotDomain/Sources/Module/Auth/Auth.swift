//
//  Auth.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/20.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import FirebaseAuth

class OAuthCallbackController {
    let redirectURL: URL
    let state: String?

    init(redirectURL: URL, state: String? = nil) {
        self.redirectURL = redirectURL
        self.state = state
    }
}

open class AuthUseCase {
    public enum Provider {
        case github(token: String)
    }

    open func signin(with provider: Provider) {
        let credential: AuthCredential = {
            switch provider {
            case .github(let token): return GitHubAuthProvider.credential(withToken: token)
            }
        }()
        Auth.auth().signInAndRetrieveData(with: credential) { (result, _) in
            result?.additionalUserInfo?.isNewUser
        }
    }
}
