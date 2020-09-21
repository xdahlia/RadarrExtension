//
//  AlertService.swift
//  Share
//
//  Created by Ivan Ou on 8/23/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import UIKit

final class AlertService {
    
    static let shared = AlertService()
    
    private init() {
    }
    
    //MARK: - Display Alerts -
    
    // Display alert box and auto dismiss after delay
    func displayAlert(
        sender: UIViewController,
        title: String,
        message: String
    ) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            sender.present(
                alert,
                animated:true,
                completion:{
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats:false, block: {_ in
                    
                        sender.dismiss(
                            animated: true,
                            completion: nil
                        )
                        sender.extensionContext!.completeRequest(
                            returningItems: [],
                            completionHandler: nil
                        )
                    
                    })
            })
        }
    
    }
    
    // Display alert box with options to dismiss itself or share sheet as well
    func displayErrorAlert(
        sender: UIViewController,
        title: String,
        message: String,
        dismissShareSheet: Bool
    ) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(
                
                UIAlertAction(
                    title: "Ok",
                    style: UIAlertAction.Style.default,
                    handler: { (action: UIAlertAction!) -> () in
                
                        if dismissShareSheet {
                            
                            // Dismiss share sheet
                            sender.extensionContext!.completeRequest(
                                returningItems: [],
                                completionHandler: nil
                            )
                        }
                    }
                )
            )
            
            // Dismiss itself
            sender.present(
                alert, animated: true,
                completion: nil
            )
        }
    }
    
}
