//
//  TMDBService.swift
//  Share
//
//  Created by Ivan Ou on 8/22/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

class TMDBService {
    
    static let shared = TMDBService()
    
    var ImdbId: String = "" {
        didSet {
            setProperties()
        }
    }
    private(set) var TmdbId: Int = 0
    private(set) var title: String = ""
    private(set) var release_date: Int = 0
    private(set) var poster_path: String = ""
    var tmdbAPIKey: String = ""
 
    // Set movie details triggered by tmdbId change
    private func setProperties() {
        
        guard let url = constructTMDBurlFromId(ImdbId: self.ImdbId, tmdbAPIKey: self.tmdbAPIKey) else {
            return
        }
        
        fetchJsonFrom(url: url) { (jsonString, error) in
            
            guard let json = jsonString else {
                return
            }
            // Set movie details from JSON
            if let tmdb = self.jsonToTMDB(json: json)?.movie_results[0] {
                
                self.TmdbId = tmdb.id
                self.title = tmdb.title
                self.release_date = self.extractYearFromDate(date: tmdb.release_date)
                self.poster_path = "https://image.tmdb.org/t/p/w1280\(tmdb.poster_path)"
                
            }
        }
        
    }
    
    // Construct TMDB API url with given IMDB movie id
    private func constructTMDBurlFromId(ImdbId: String, tmdbAPIKey: String) -> URL? {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3/find/" + ImdbId
        components.queryItems = [
            URLQueryItem(name: "external_source", value: "imdb_id"),
            URLQueryItem(name: "api_key", value: tmdbAPIKey)
        ]
        
        if let url = components.url {
            return url
        } else {
            return nil
        }
        
    }
    
    // Fetch JSON from url
    private func fetchJsonFrom(url: URL, userCompletionHandler: @escaping (String?, Error?) -> Void) {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let json = data {
                let jsonString = String(data: json, encoding: .utf8)!
                userCompletionHandler(jsonString, nil)
            }
            
            if let error = error {
                // FIXME: Fix error handling
                //                self.displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                userCompletionHandler(nil, error)
            }
            
        }
        task.resume()
    }
    
    // Instantiate TMDB model from JSON
    private func jsonToTMDB(json: String) -> TMDB? {
        
        let decoder = JSONDecoder()
        
        if let jsonData = json.data(using: .utf8) {
            
            do {
                let model = try decoder.decode(TMDB.self, from: jsonData)
                return model
                
            } catch {
                // FIXME: Fix error handling
                //                displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                return nil
                
            }
        } else {
            return nil
        }
    }
    
    // Extract year from date
    private func extractYearFromDate(date: String) -> Int {
        guard let int = Int(String(date.prefix(4))) else { return 0 }
        return int
    }
    
}
