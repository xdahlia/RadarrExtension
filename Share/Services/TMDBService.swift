//
//  TMDBService.swift
//  Share
//
//  Created by Ivan Ou on 8/22/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import UIKit

final class TMDBService {
    
    static let shared = TMDBService()
    private var alertService = AlertService.shared
    var viewController = UIViewController()
    
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
        
        guard let url = constructTMDBurlFromId(
            ImdbId: self.ImdbId,
            tmdbAPIKey: self.tmdbAPIKey
        ) else {
            return
        }
        
        fetchJsonFrom(url: url) { (jsonString, error) in
            
            if let json = jsonString {
                
                if let tmdb = self.jsonToTMDB(json: json) {
                    let results = tmdb.movie_results

                    if results.count != 0 {
                        
                        let title = results[0]
    
                        // Set movie details from JSON
                        self.TmdbId = title.id
                        self.title = title.title
                        self.poster_path = "https://image.tmdb.org/t/p/w1280\(title.poster_path)"
                        if let year = self.extractYearFromDate(date: title.release_date) {
                            self.release_date = year
                        }
                        
                    } else {
                        
                        self.alertService.displayErrorUIAlertController(
                            sender: self.viewController,
                            title: "Error",
                            message: "Shared link does not contain movie data",
                            dismissShareSheet: false
                        )
                        
                    }
                }
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
//                print(jsonString)
                userCompletionHandler(jsonString, nil)
            }
            
            if let error = error {
                
                self.alertService.displayErrorUIAlertController(
                    sender: self.viewController,
                    title: "Error",
                    message: error.localizedDescription,
                    dismissShareSheet: false
                )
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
                
                self.alertService.displayErrorUIAlertController(
                    sender: self.viewController,
                    title: "Error",
                    message: error.localizedDescription,
                    dismissShareSheet: false
                )
                return nil
                
            }
        } else {
            return nil
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


