//
//  ValidationService.swift
//  Share
//
//  Created by Ivan Ou on 8/26/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct ValidationService {
    
    static let shared = ValidationService()
    
    private init() {
    }
    
    // MARK: - Validation -

    func validateSharedURL(with url: NSURL) throws {
        
        guard url.host == "www.imdb.com" else {
            throw UrlError.notIMDb
        }
        guard url.pathComponents!.count > 2 else {
            throw UrlError.notMovie
        }
        guard url.pathComponents![1] == "title" else {
            throw UrlError.notMovie
        }
    }
    
    // Checks for valid response
    func validateRadarrResponse(with response: URLResponse) throws {
        
        guard let httpResponse =
            
            response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
            
        else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                
                if statusCode == 400 {
                    throw ResultError.fourHundred
                    
                } else if statusCode == 401 {
                    throw ResultError.fourZeroOne
                    
                } else {
                    throw ResultError.general
                }
        }
    }
    
}
