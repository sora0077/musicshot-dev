//
//  AuthorizationTokenRepository.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/20.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

public protocol AuthorizationTokenRepository {
    
    func currentToken() throws -> AuthorizationToken?
}
