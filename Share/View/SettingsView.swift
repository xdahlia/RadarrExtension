//
//  SettingsView.swift
//  Share
//
//  Created by Ivan Ou on 9/2/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import UIKit

@IBDesignable
open class SettingsView: UIView {

    //MARK: - Settings Properties -
    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var serverPortField: UITextField!
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

        setTextFieldResponderChain()
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
        serverPortField.text = settingsService.radarrServerPort
        radarrAPIKeyField.text = settingsService.radarrAPIKey
        rootFolderPathField.text = settingsService.rootFolderPath
        tmdbAPIKeyField.text = settingsService.tmdbAPIKey
    }
    
    fileprivate func setSettingsTextFieldContentTypes() {
        
        serverAddressField.textContentType = .URL
        serverPortField.textContentType = .URL
        radarrAPIKeyField.textContentType = .newPassword
        rootFolderPathField.textContentType = .URL
        tmdbAPIKeyField.textContentType = .newPassword
    }
    
    fileprivate func setTextFieldResponderChain() {
        
        UITextField.connectFields(fields: [
            serverAddressField,
            serverPortField,
            radarrAPIKeyField,
            rootFolderPathField,
            tmdbAPIKeyField
        ])
    }

}
