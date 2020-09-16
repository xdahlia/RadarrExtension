//
//  ResultError.swift
//  Share
//
//  Created by Ivan Ou on 8/26/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

enum ResultError: Error {
    
    case fourHundred
    case fourZeroOne
    case general
}

extension ResultError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .fourHundred:
            return NSLocalizedString(
                "Movie already exists",
                comment: ""
            )
        case .fourZeroOne:
            return NSLocalizedString(
                "The Radarr API Key may be wrong",
                comment: ""
            )
        case .general:
            return NSLocalizedString(
                "A problem ocurred sending movie to Radarr",
                comment: ""
            )
        }
    }
}
