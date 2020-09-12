//
//  ResultHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/8/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct ResultHandler {
      
    // Checks for valid response
    func validateRadarrResponse(with response: URLResponse) throws {
        
        print("ResultHandler.validateRadarrResponse")
        
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
