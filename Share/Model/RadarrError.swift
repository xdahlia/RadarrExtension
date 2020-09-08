//
//  RadarrError.swift
//  Share
//
//  Created by Ivan Ou on 9/8/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

enum RadarrError: Error {
    
    case cannotExtractYear
    case cannotConvertTitleSlug
    case cannotEncodeJSON
    case cannotConstructURL
    case cannotConstructModel
    case general
}

extension RadarrError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .cannotExtractYear:
            return NSLocalizedString(
                "Unable to extract year from date",
                comment: ""
            )
        case .cannotConvertTitleSlug:
            return NSLocalizedString(
                "Unable to convert title to titleSlug",
                comment: ""
            )
        case .cannotEncodeJSON:
            return NSLocalizedString(
                "Unable to encode JSON",
                comment: ""
            )
        case .cannotConstructURL:
            return NSLocalizedString(
                "Unable to construct Radarr URL",
                comment: ""
            )
        case .cannotConstructModel:
            return NSLocalizedString(
                "Unable to construct Radarr model",
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
