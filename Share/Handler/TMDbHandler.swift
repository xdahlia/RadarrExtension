//
//  TMDbHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/4/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

class TMDbHandler {
    
    static let shared = TMDbHandler()
    
    let settingsService = SettingsService.shared
    
    func fetchMovieData(IMDbId: String) throws -> TMDB.Movies {
        
        guard settingsService.TMDbAPIKeyIsSet() else {
            throw TMDbError.APIKeyNotSet
        }
        
        guard let TMDbUrl = constructTMDbUrlFromId(IMDbId, tmdbAPIKey: settingsService.tmdbAPIKey) else {
            throw TMDbError.cannotConstructUrl
        }
        
        guard let jsonString = returnJSONStringFrom(url: TMDbUrl) else {
            throw TMDbError.cannotReturnJSONString
        }
        
        do {
            let tmdb = try jsonToTMDB(json: jsonString)
            return tmdb
        } catch {
            throw TMDbError.cannotConvertToModel
        }
        
    }
    
    private func returnJSONStringFrom(url: URL) -> String? {
        
        var jsonResult: String?
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let json = data {
                jsonResult = String(data: json, encoding: .utf8)
            }
            
            
            // TODO: Implement error handling
//            if let error = error {
//
//            }
        }
        task.resume()
        
        return jsonResult
        
    }
    
    // Construct TMDB API url with given IMDB movie id
    private func constructTMDbUrlFromId(_ ImdbId: String, tmdbAPIKey: String) -> URL? {
        
        if ImdbId.isEmpty, tmdbAPIKey.isEmpty {
            return nil
        }

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
    
    // Instantiate TMDB model from JSON
    private func jsonToTMDB(json: String) throws -> TMDB.Movies {
        
        let decoder = JSONDecoder()
        
        if let jsonData = json.data(using: .utf8) {
            
            do {
                let model = try decoder.decode(TMDB.self, from: jsonData)
                
                let results = model.movie_results
                
                if results.count != 0 {

                    return results[0]

//                    // Set movie details from JSON
//                    self.TmdbId = title.id
//                    self.title = title.title
//                    self.poster_path = "https://image.tmdb.org/t/p/w1280\(title.poster_path)"
//                    if let year = self.extractYearFromDate(date: title.release_date) {
//                        self.release_date = year
//                    }

                } else {
                    throw TMDbError.movieNotFound
                }
                
            } catch {
                throw TMDbError.cannotDecodeJSON
                
            }
        } else {
            throw TMDbError.general
        }
    }
    
    // Extract year from date
    private func extractYearFromDate(date: String) -> Int? {
        
        if let year = Int(String(date.prefix(4))) {
            return year
        } else {
            return nil
        }
        
    }
    
}
