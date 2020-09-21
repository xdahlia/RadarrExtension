//
//  SettingsError.swift
//  Share
//
//  Created by Ivan Ou on 9/21/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

enum SettingsError: Error {
    
    case radarrServer
    case radarrPort
    case radarrAPI
    case radarrPath
    case TMDbAPI
}

extension SettingsError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .radarrServer:
            return NSLocalizedString(
                "Please check Radarr server address",
                comment: ""
            )
        case .radarrPort:
            return NSLocalizedString(
                "Please check Radarr server port",
                comment: ""
            )
        case .radarrAPI:
            return NSLocalizedString(
                "Please check Radarr server API Key",
                comment: ""
            )
        case .radarrPath:
            return NSLocalizedString(
                "Please check Radarr server media path",
                comment: ""
            )
        case .TMDbAPI:
            return NSLocalizedString(
                "Please check TMDb API Key",
                comment: ""
            )

        }
    }
}
