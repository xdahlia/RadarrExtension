//
//  ViewController.swift
//  TestExtension
//
//  Created by Ivan Ou on 7/28/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var logoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var logoVerticalPosition: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        logoViewHeight.constant = 80
        logoWidth.constant = 173
        logoHeight.constant = 80
        logoVerticalPosition.constant = 0
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        
        triggerNetworkAlert()
        
    }
    
    // Ping local network to trigger local network alert dialog
    fileprivate func triggerNetworkAlert() {
        
        // Ping once
        let once = try? SwiftyPing(host: "192.168.1.1", configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        once?.observer = { (response) in
            if let duration = response.duration {
                print(duration)
            }
        }
        once?.targetCount = 1
        try? once?.startPinging()
    }

}

