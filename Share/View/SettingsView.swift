//
//  SettingsView.swift
//  Share
//
//  Created by Ivan Ou on 9/2/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import UIKit

@IBDesignable
open class SettingsView: UIView, UITextFieldDelegate {

    //MARK: - Settings Properties -
    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var radarrAPIKeyField: UITextField!
    @IBOutlet weak var rootFolderPathField: UITextField!
    @IBOutlet weak var tmdbAPIKeyField: UITextField!
    
    var view: UIView!
    
    private var settingsService = SettingsService.shared
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        
        setupView()
        
        settingsService.load()
        
        setSettingsTextFieldContent()
        setSettingsTextFieldContentTypes()
        setSettingsTextFieldDelegates()
    }
    
    fileprivate func setupView() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        self.view = view
    }
    
    fileprivate func setSettingsTextFieldContent() {
        
        // Populate settings text fields with data from Settings model
        serverAddressField.text = settingsService.radarrServerAddress
        radarrAPIKeyField.text = settingsService.radarrAPIKey
        rootFolderPathField.text = settingsService.rootFolderPath
        tmdbAPIKeyField.text = settingsService.tmdbAPIKey
    }
    
    fileprivate func setSettingsTextFieldContentTypes() {
        
        serverAddressField.textContentType = .URL
        radarrAPIKeyField.textContentType = .newPassword
        rootFolderPathField.textContentType = .URL
        tmdbAPIKeyField.textContentType = .newPassword
    }
    
    fileprivate func setSettingsTextFieldDelegates() {
        
        // Register text field delegates
        serverAddressField.delegate = self
        radarrAPIKeyField.delegate = self
        rootFolderPathField.delegate = self
        tmdbAPIKeyField.delegate = self
    }
    
    // Set textfields as first responder
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }

}
