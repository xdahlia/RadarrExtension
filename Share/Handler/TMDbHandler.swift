//
//  TMDbHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/4/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import PromiseKit
import AwaitKit

// Takes IMDb ID and returns TMDb model
class TMDbHandler {
       
    let settingsService = SettingsService.shared
    
    func fetchMovieData(IMDbId: String) throws -> TMDB.Movies {
        
        print("TMDbHandler.fetchMovieData")
        
        guard settingsService.TMDbAPIKeyIsSet() else {
            throw TMDbError.APIKeyNotSet
        }
        
        guard let TMDbUrl = try constructTMDbUrlFromId(IMDbId, tmdbAPIKey: settingsService.tmdbAPIKey) else {
            throw TMDbError.cannotConstructUrl
        }
        
        guard let jsonString = try await(returnJSONStringFrom(url: TMDbUrl)) else {
            throw TMDbError.cannotReturnJSONString
        }
        
        guard let tmdb = try jsonToTMDB(json: jsonString) else {
            throw TMDbError.cannotConvertToModel
        }
        
        return tmdb
    }
    
    // Construct TMDB API url with given IMDB movie id
    private func constructTMDbUrlFromId(_ ImdbId: String, tmdbAPIKey: String) throws -> URL? {
        
        print("TMDbHandler.constructTMDbUrlFromId")
        
        if ImdbId.isEmpty, tmdbAPIKey.isEmpty {
            fatalError("IMDb ID / TMDb API Key should not be empty at this point")
        }

        var components = URLComponents()
            components.scheme = "https"
            components.host = "api.themoviedb.org"
            components.path = "/3/find/" + ImdbId
            components.queryItems = [
                URLQueryItem(name: "external_source", value: "imdb_id"),
                URLQueryItem(name: "api_key", value: tmdbAPIKey)
            ]
        
        guard let url = components.url else {
            throw TMDbError.cannotConstructUrl
        }
        
        return url
    }
    
    // Retrive JSON from URL
    private func returnJSONStringFrom(url: URL) -> Promise<String?> {
        
        print("TMDbHandler.returnJSONStringFrom")
        
        return Promise { result in
            
            let session = URLSession.shared
  
            session.configuration.waitsForConnectivity = true
            session.configuration.timeoutIntervalForResource = 10
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if let json = data {
                    print(String(data: json, encoding: .utf8).debugDescription)
                    result.fulfill(String(data: json, encoding: .utf8))
                }
    
                if let error = error {
                    result.reject(error)
                }
            }
            task.resume()
        }
        
    }
    
    // Instantiate TMDB model from JSON
    private func jsonToTMDB(json: String) throws -> TMDB.Movies? {
        
        print("TMDbHandler.jsonToTMDB")
        
        let decoder = JSONDecoder()
        
        if let jsonData = json.data(using: .utf8) {
            
            do {
                let model = try decoder.decode(TMDB.self, from: jsonData)
                
                let results = model.movie_results
                
                if results.count != 0 {

                    return results[0]

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

}
