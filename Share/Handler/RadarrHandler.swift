//
//  RadarrHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/8/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import PromiseKit
import AwaitKit

// Takes TMDb model and returns Response
class RadarrHandler {

    let settingsService = SettingsService.shared
    
    func sendMovieToRadarr(movie: TMDB.Movies) throws -> URLResponse? {
        
        print("RadarrHandler.sendMovieToRadarr")

        guard let radarrModel = try constructRadarrModelFromTMDb(data: movie) else {
            throw RadarrError.cannotConstructModel
        }
    
        guard let radarrJSON = try constructJSONFromRadarr(model: radarrModel) else {
            throw RadarrError.cannotConstructJSON
        }
        
        guard let radarrURL = try constructRadarrUrl(
            serverAddress: settingsService.radarrServerAddress,
            serverPort: settingsService.radarrServerPort,
            apiKey: settingsService.radarrAPIKey
        ) else {
            throw RadarrError.cannotConstructURL
        }
        
        guard let response = try await(postJSON(using: radarrJSON, to: radarrURL)) else {
            throw RadarrError.general
        }
        
        return response
    }
    
    // POST JSON to Radarr server
    private func postJSON(using data: Data, to url: URL) -> Promise<URLResponse?> {
        
        print("RadarrHandler.postJSON")
            
        var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.httpMethod = "POST"
        
        let session = URLSession.shared
        
        return Promise { result in
        
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let unwrappedResponse = response {
                    
                    print(unwrappedResponse.debugDescription)
                    
                    result.fulfill(unwrappedResponse)
                }

                if let error = error {
                    result.reject(error)
                }
                
            }
            task.resume()
        }
    }
    
    private func constructJSONFromRadarr(model: Radarr) throws -> Data? {
        
        print("RadarrHandler.constructJSONFromRadarr")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        do {
            let json = try encoder.encode(model)
            print(String(data: json, encoding: .utf8).debugDescription)
            return json
            
        } catch {
            throw RadarrError.cannotEncodeJSON
        }
    }

    private func constructRadarrModelFromTMDb(data: TMDB.Movies) throws -> Radarr? {
        
        print("RadarrHandler.constructRadarrModelFromTMDb")
        
        guard let year = extractYearFromDate(date: data.release_date) else {
            throw RadarrError.cannotExtractYear
        }
        
        guard let titleSlug = data.title.convertedToSlug() else {
            throw RadarrError.cannotConvertTitleSlug
        }
        
        let radarrModel = Radarr(
            title: data.title,
            tmdbId: data.id,
            titleSlug: titleSlug,
            monitored: settingsService.searchNow,
            year: year,
            rootFolderPath: settingsService.rootFolderPath,
            searchNow: settingsService.searchNow,
            imageUrl: "https://image.tmdb.org/t/p/w1280\(data.poster_path)"
        )
        
        return radarrModel
    }

    private func constructRadarrUrl(serverAddress: String, serverPort: String, apiKey: String) throws -> URL? {
        
        print("RadarrHandler.constructRadarrUrl")
        
        if serverAddress.isEmpty, apiKey.isEmpty {
            fatalError("Radarr server address and API Key should not be empty at this point")
        }
        
        var components = URLComponents()
            components.scheme = "http"
            components.host = serverAddress
            components.port = Int(serverPort) // TODO: Add error handling
            components.path = "/api/movie"
            components.queryItems = [
                URLQueryItem(name: "apikey", value: apiKey)
            ]
        
        guard let url = components.url else {
            throw RadarrError.cannotConstructURL
        }
        
        return url
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
