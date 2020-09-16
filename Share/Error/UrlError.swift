//
//  UrlError.swift
//  Share
//
//  Created by Ivan Ou on 8/26/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

enum UrlError: Error {
    
    case notIMDb
    case notMovie
    case noResult
    case general
}

extension UrlError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .notIMDb:
            return NSLocalizedString(
                "Link must be shared from IMDb app or website",
                comment: ""
            )
        case .notMovie:
            return NSLocalizedString(
                "Shared link is not an IMDb movie page",
                comment: ""
            )
        case .noResult:
            return NSLocalizedString(
                "Shared link does not contain movie data",
                comment: ""
            )
        case .general:
            return NSLocalizedString(
                "There was a problem with the shared URL",
                comment: ""
            )

        }
    }
}
