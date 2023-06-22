//
//  PathStatus.swift
//  Switcheroo
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

@objcMembers
class PathStatus: NSObject {
    
    // MARK: Init
    init(originalURL: URL, response: HTTPURLResponse?, redirect: HTTPURLResponse?, error: Error?) {
        self.code = response?.statusCode ?? 0

        // save intermediate URL if:
        // - there was a redirect
        // - the redirect changed the path (this part is to ignore redirects like /contact -> /contact/)
        self.redirect = (redirect != nil && originalURL.pathComponents != response?.url?.pathComponents) ? response?.url : nil
        self.redirectCode = self.redirect == nil ? nil : redirect?.statusCode

        switch code {
        case 100..<300:
            badge = .success
        case 300..<400:
            badge = .warning
        default:
            badge = .error
        }
    }

    // MARK: Types
    @objc enum Badge: Int {
        case success, warning, error
    }

    // MARK: Properties
    let badge: Badge
    let code: Int
    let redirect: URL?
    let redirectCode: Int?
    
    // MARK: CSV
    var csvStatus: String {
        let csvBadge: String
        switch badge {
        case .success:
            csvBadge = "OK"
        case .warning:
            csvBadge = "REDIRECTION"
        case .error:
            csvBadge = "ERROR"
        }
        
        return csvBadge + " - " + String(code)
    }
}
