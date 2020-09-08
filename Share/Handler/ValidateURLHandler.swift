//
//  ValidationService.swift
//  Share
//
//  Created by Ivan Ou on 8/26/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct ValidateURLHandler {
    
    static let shared = ValidateURLHandler()
    
    private init() {
    }
    
    // MARK: - URL Validation -

    func returnIMDbId(from url: NSURL) throws -> String {
        
        guard url.host == "www.imdb.com" else {
            throw UrlError.notIMDb
        }
        guard url.pathComponents!.count > 2 else {
            throw UrlError.notMovie
        }
        guard url.pathComponents![1] == "title" else {
            throw UrlError.notMovie
        }
        
        return url.pathComponents![2]
    }
    
}
