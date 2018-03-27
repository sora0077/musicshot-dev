//
//  GetPreviewURL.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/13.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import APIKit

func appleStoreFront(locale: Locale = Locale.current) -> String {
    return "143462-9,4"
}

struct GetPreviewURL: Request {
    typealias Response = (URL, Int)
    enum Error: Swift.Error {
        case notFound
    }
    let baseURL: URL
    let method = HTTPMethod.get
    let path = ""
    var headerFields: [String: String] {
        return [
            "X-Apple-Store-Front": appleStoreFront(locale: locale)
        ]
    }
    var dataParser: DataParser {
        struct DataParser: APIKit.DataParser {
            var contentType: String? = "application/x-apple-plist"

            func parse(data: Data) throws -> Any {
                return try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            }
        }
        return DataParser()
    }

    private let id: Int
    private let locale: Locale

    init(id: Int, url: URL, locale: Locale = Locale.current) {
        self.id = id
        self.baseURL = url
        self.locale = locale
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if let items = (object as? [String: Any])?["items"] as? [[String: Any]] {
            for item in items {
                guard let id = item["item-id"] as? Int, self.id == id else { continue }
                return try getPreviewURL(item: item)
            }
        }
        throw Error.notFound
    }
}

private func getPreviewURL(item: [String: Any]) throws -> (URL, Int) {
    func value(preview: String, duration: Int) -> (URL, Int)? {
        guard let url = URL(string: preview) else { return nil }
        return (url, duration)
    }

    func decode() -> (URL, Int)? {
        guard let offers = item["store-offers"] as? [String: Any] else {
            return nil
        }
        if let plus = offers["PLUS"] as? [String: Any] {
            if let p = plus["preview-url"] as? String,
                let d = plus["preview-duration"] as? Int {
                return value(preview: p, duration: d)
            }
        } else if let hqpre = offers["HQPRE"] as? [String: Any] {
            if let p = hqpre["preview-url"] as? String,
                let d = hqpre["preview-duration"] as? Int {
                return value(preview: p, duration: d)
            }
        }
        return nil
    }

    guard let ret = decode() else {
        throw GetPreviewURL.Error.notFound
    }
    return ret
}

// MARK: - Preview Data
struct GetPreviewData: Request {
    typealias Response = Data
    let baseURL: URL
    let method = HTTPMethod.get
    let path = ""
    var dataParser: DataParser {
        struct DataParser: APIKit.DataParser {
            var contentType: String?

            func parse(data: Data) throws -> Any {
                return data
            }
        }
        return DataParser()
    }

    init(url: URL) {
        self.baseURL = url
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        // swiftlint:disable:next force_cast
        return object as! Data
    }
}
