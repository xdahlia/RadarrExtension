//
//  TextFieldExtension.swift
//  Share
//
//  Created by Ivan Ou on 9/12/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    
    
    // By Amos Joshua
    // https://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons
    class func connectFields(fields:[UITextField]) -> Void {
        
        guard let last = fields.last else {
            return
        }
        
        for i in 0 ..< fields.count - 1 {
            
            fields[i].returnKeyType = .next
            fields[i].addTarget(
                fields[i+1],
                action: #selector(UIResponder.becomeFirstResponder),
                for: .editingDidEndOnExit
            )
        }
        
        last.returnKeyType = .done
        last.addTarget(
            last,
            action: #selector(UIResponder.resignFirstResponder),
            for: .editingDidEndOnExit
        )
    }
    
}
