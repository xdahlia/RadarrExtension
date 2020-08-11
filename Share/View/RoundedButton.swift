//
//  RoundedButton.swift
//  Share
//
//  Created by Ivan Ou on 8/10/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

// from https://medium.com/@filswino/easiest-implementation-of-rounded-buttons-in-xcode-6627efe39f84
import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
        self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
