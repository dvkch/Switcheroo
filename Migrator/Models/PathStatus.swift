//
//  PathStatus.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

@objcMembers
class PathStatus: NSObject {
    
    // MARK: Init
    init(badge: Badge, code: Int) {
        self.badge = badge
        self.code = code
        super.init()
    }
    
    init(response: HTTPURLResponse?, error: Error?) {
        self.code = response?.statusCode ?? 0
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
