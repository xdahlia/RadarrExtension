//
//  RadarrService.swift
//  Share
//
//  Created by Ivan Ou on 8/22/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import UIKit

class RadarrService {
    
    static let shared = RadarrService()
    var alertService = AlertService.shared
    var viewController = UIViewController()
    
    // Encode JSON from Radarr model
    func radarrToJSON(data: Radarr) -> Data? {
        
        debugPrint(data)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        do {
            let json = try encoder.encode(data)
            return json

        } catch {
            self.alertService.displayErrorUIAlertController(sender: self.viewController, title: "Error", message: error.localizedDescription, dismissShareSheet: false)
            print(error.localizedDescription)
            return nil
        }
    }
    
    // POST JSON to Radarr server
    func postJSON(from data: Data, url: String) {
        
        if let url = URL(string: url) {
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.httpMethod = "POST"
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    self.alertService.displayErrorUIAlertController(sender: self.viewController, title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                    print(error.localizedDescription)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode
                        
                        if statusCode == 400 {
                            self.alertService.displayErrorUIAlertController(sender: self.viewController, title: "Error", message: "Movie already exists", dismissShareSheet: false)
                            print("Movie already exists")
                        } else if statusCode == 401 {
                            self.alertService.displayErrorUIAlertController(sender: self.viewController, title: "Error", message: "The Radarr API Key may be wrong", dismissShareSheet: false)
                            print("The Radarr API Key may be wrong")
                        } else {
                            self.alertService.displayErrorUIAlertController(sender: self.viewController, title: "Error", message: "A problem ocurred sending movie to Radarr", dismissShareSheet: false)
                            print("A problem ocurred sending movie to Radarr")
                        }
                        
                    return
                }
                
                self.alertService.displayUIAlertController(sender: self.viewController, title: "Done", message: "Movie sent to Radarr!")
                
            }
            task.resume()
        }
    }

}