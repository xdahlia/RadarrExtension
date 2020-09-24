//
//  ExtensionError.swift
//  Share
//
//  Created by Ivan Ou on 9/8/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

enum ExtensionError: Error {
    
    case cannotExtractProvider
    case cannotExtractAttachment
    case cannotLoadAttachment
    case cannotLoadURL
    case general
}

extension ExtensionError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .cannotExtractProvider:
            return NSLocalizedString(
                "Unable to extract Provider from Context",
                comment: ""
            )
        case .cannotExtractAttachment:
            return NSLocalizedString(
                "Unable to extract Attachment from Provider",
                comment: ""
            )
        case .cannotLoadAttachment:
            return NSLocalizedString(
                "Unable to load attachments from Provider",
                comment: ""
            )
        case .cannotLoadURL:
            return NSLocalizedString(
                "Unable to load URL from attachment",
                comment: ""
            )
        case .general:
            return NSLocalizedString(
                "A problem occured while handling shared extension",
                comment: ""
            )

        }
    }
}
