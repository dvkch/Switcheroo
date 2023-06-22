//
//  URL+SY.swift
//  Switcheroo
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
    
    func updatingHost(_ host: String, scheme: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.host = host
        components.scheme = scheme
        return components.url!
    }
}

extension URLQueryItem {
    var urlValue: String {
        let name = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let value = self.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! ?? ""
        return name + "=" + value
    }
}
