//
//  TextFieldDelegate.swift
//  Share
//
//  Created by Ivan Ou on 8/27/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import UIKit

extension ShareViewController: UITextFieldDelegate {
    
    // Set textfields as first responder
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
