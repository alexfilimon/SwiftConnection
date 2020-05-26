//
//  SessionError.swift
//  
//
//  Created by Alexander Filimonov on 01/03/2020.
//

import Foundation

/// Error that descibes custom connection errors
public enum ConnectionError: LocalizedError {
    case couldntCreateUrl
    case networkError(Error)
    case networkCodeError(jsonData: [String: Any], code: Int)
    case dataIsNil

    // MARK: - LocalizedError

    public var localizedDescription: String {
        switch self {
        case .couldntCreateUrl:
            return "Couldnt create url"
        case .networkError(let error):
            return "Network error: \(error)"
        case .networkCodeError(let jsonData, let code):
            return "Network error with code \(code), data: \(jsonData)"
        case .dataIsNil:
            return "Unknown network error"
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }

}
