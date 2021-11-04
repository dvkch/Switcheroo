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

    // MARK: Types
    @objc enum Badge: Int {
        case success, warning, error
    }

    // MARK: Properties
    let badge: Badge
    let code: Int
}
