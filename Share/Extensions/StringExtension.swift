//
//  StringExtension.swift
//  Share
//
//  Created by Ivan Ou on 8/27/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

// Converts string "movie title's string" to slug "movie-title-s-string"
// From Hacking With Swift
extension String {
    
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")
    
    public func convertedToSlug() -> String? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
            let result = urlComponents.filter { $0 != "" }.joined(separator: "-")
            
            if result.count > 0 {
                return result
            }
        }
        
        return nil
    }
}
