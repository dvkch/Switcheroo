//
//  AppError.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

enum AppError: Int, Error {
    case invalidHost
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidHost: return "Invalid host"
        }
    }
}
