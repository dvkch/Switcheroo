//
//  URL+SY.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

extension URL {
    var withoutQuery: URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.queryItems = nil
        return components.url!
    }
    
    var pathWithQuery: String {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        guard let queryItems = components.queryItems else { return path }
        return path + "?" + queryItems.map(\.urlValue).joined(separator: "&")
    }
}

extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        return lhs.absoluteURL.absoluteString < rhs.absoluteURL.absoluteString
    }
}

extension URLQueryItem {
    var urlValue: String {
        let name = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let value = self.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! ?? ""
        return name + "=" + value
    }
}
