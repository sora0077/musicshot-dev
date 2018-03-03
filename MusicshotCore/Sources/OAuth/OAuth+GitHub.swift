//
//  OAuth+GitHub.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/03.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FoundationSupport
import APIKit
import RxSwift

extension OAuth {
    public final class GitHub {
        public var authorizeURL: URL {
            var comps = URLComponents(string: "https://github.com/login/oauth/authorize")!
            comps.queryItems = [
                "client_id": env.githubClientId,
                "redirect_uri": redirectURL.absoluteString,
                "state": state]
                .compactValues()
                .map { key, value in
                    URLQueryItem(name: key, value: value)
                }
            return comps.url!
        }
        private let redirectURL: URL
        private let state: String?
        private let observable: Single<Void>

        init(redirectURL: URL, state: String? = nil, observable: Single<Void>) {
            self.redirectURL = redirectURL
            self.state = state
            self.observable = observable
        }

        public func asSingle() -> Single<Void> {
            return observable.subscribeOn(MainScheduler.instance)
        }
    }
}

extension OAuth.GitHub {
    struct GetAccessToken: APIKit.Request {
        var method: HTTPMethod { return .post }
        var baseURL: URL { return URL(string: "https://github.com")! }
        var path: String { return "/login/oauth/access_token" }
        var parameters: Any? {
            return [
                "client_id": clientId,
                "client_secret": clientSecret,
                "code": code,
                "redirect_uri": redirectURL?.absoluteString,
                "state": state
            ].compactValues()
        }
        var dataParser: DataParser {
            struct DataParser: APIKit.DataParser {
                var contentType: String? = JSONDataParser(readingOptions: []).contentType

                func parse(data: Data) throws -> Any {
                    return data
                }
            }
            return DataParser()
        }

        private let clientId: String
        private let clientSecret: String
        private let code: String
        private let redirectURL: URL?
        private let state: String?

        init(clientId: String, clientSecret: String, code: String, redirectURL: URL?, state: String?) {
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.code = code
            self.redirectURL = redirectURL
            self.state = state
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
            guard let data = object as? Data else {
                throw OAuth.Error.unexpectedObject(object, urlResponse)
            }
            return try JSONDecoder().decode(Response.self, from: data)
        }

        struct Response: Decodable {
            let accessToken: String
            let scope: String
            let tokenType: String

            private enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case scope = "scope"
                case tokenType = "token_type"
            }
        }
    }
}
