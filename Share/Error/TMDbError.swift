//
//  ValidationError.swift
//  Share
//
//  Created by Ivan Ou on 8/26/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

enum TMDbError: Error {
    
    case APIKeyNotSet
    case noMovieData
    case cannotDecodeJSON
    case cannotConstructUrl
    case cannotConvertToModel
    case cannotRetrieveJSON
    case movieNotFound
    case cannotReturnJSONString
    case general
}

extension TMDbError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .APIKeyNotSet:
            return NSLocalizedString(
                "TMDb API Key has not been set",
                comment: ""
            )
        case .noMovieData:
            return NSLocalizedString(
                "Shared link does not contain movie data",
                comment: ""
            )
        case .cannotDecodeJSON:
            return NSLocalizedString(
                "Unable to decode JSON",
                comment: ""
            )
        case .cannotConstructUrl:
            return NSLocalizedString(
                "Unable to construct TMDb url",
                comment: ""
            )
        case .cannotConvertToModel:
            return NSLocalizedString(
                "Unable to convert TMDb JSON to data model",
                comment: ""
            )
        case .cannotRetrieveJSON:
            return NSLocalizedString(
                "Unable to retrive JSON from TMDb",
                comment: ""
        )
        case .movieNotFound:
            return NSLocalizedString(
                "Movie not found on TMDb",
                comment: ""
        )
        case .cannotReturnJSONString:
            return NSLocalizedString(
                "Unable to return JSON String",
                comment: ""
        )
        case .general:
            return NSLocalizedString(
                "Failed to retrieve movie data from TMDb",
                comment: ""
            )
        }
    }
}
