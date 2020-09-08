//
//  ViewExtension.swift
//  Share
//
//  Created by Ivan Ou on 9/3/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import UIKit

extension ShareViewController {
    
    func expandSettingsView() {
        self.viewHeight.constant = 240
        self.settingsView.isHidden = true
        self.settingsView.alpha = 0
        
        // Expand container, then fade
        UIView.animate(withDuration: 0.3, animations: {
            self.viewHeight.constant = 490
            self.settingsView.isHidden = false
        }, completion: {
            finished in
            UIView.animate(withDuration: 0.2) {
                self.settingsView.alpha = 1
            }
        })
    }
    
    func collapseSettingsView() {
        self.viewHeight.constant = 490
        self.settingsView.isHidden = false
        self.settingsView.alpha = 1
        
        // Fade, then collapse container
        UIView.animate(withDuration: 0.2, animations: {
            self.settingsView.alpha = 0
        }, completion: {
            (finished) in
            UIView.animate(withDuration: 0.3) {
                self.viewHeight.constant = 240
                self.settingsView.isHidden = true
            }
        })
    }
    
}
