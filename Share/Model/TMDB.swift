//
//  TMDB.swift
//  Share
//
//  Created by Ivan Ou on 7/29/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct TMDB: Codable {
    
    let movie_results: [Movies]
    
    struct Movies: Codable {
        let id: Int
        let title: String
        let release_date: String
        let poster_path: String
    }
    
}
