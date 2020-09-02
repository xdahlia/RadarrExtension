//
//  RadarrService.swift
//  Share
//
//  Created by Ivan Ou on 8/22/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import UIKit

final class RadarrService {
    
    static let shared = RadarrService()
    private var alertService = AlertService.shared
    private var validationService = ValidationService.shared
    var viewController = UIViewController()
    
    private init() {
    }
    
    // Encode JSON from Radarr model
    func radarrToJSON(data: Radarr) -> Data? {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        do {
            let json = try encoder.encode(data)
            return json
            
        } catch {
            
            self.alertService.displayErrorUIAlertController(
                sender: self.viewController,
                title: "Error",
                message: error.localizedDescription,
                dismissShareSheet: false
            )
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
                    
                    self.alertService.displayErrorUIAlertController(
                        sender: self.viewController,
                        title: "Error", message:
                        error.localizedDescription,
                        dismissShareSheet: false
                    )
                    return
                }
                
                do {
                    try self.validationService.validateRadarrResponse(with: response!)
                    
                } catch {
                    
                    self.alertService.displayErrorUIAlertController(
                        sender: self.viewController,
                        title: "Error",
                        message: error.localizedDescription,
                        dismissShareSheet: true
                    )
                }

                self.alertService.displayUIAlertController(
                    sender: self.viewController,
                    title: "Done",
                    message: "Movie sent to Radarr!"
                )
                
            }
            task.resume()
        }
    }
}
