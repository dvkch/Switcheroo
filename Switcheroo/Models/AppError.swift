//
//  AppError.swift
//  Switcheroo
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

enum AppError: Int, Error {
    case invalidHost, invalidFileType, noSaveSupport
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidHost:      return "Invalid host"
        case .invalidFileType:  return "Invalid file type"
        case .noSaveSupport:    return "Saving is not supported"
        }
    }
}
