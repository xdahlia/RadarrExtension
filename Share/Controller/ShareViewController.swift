//
//  ShareViewController.swift
//  Share
//
//  Created by Ivan Ou on 7/28/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import UIKit
// import MobileCoreServices

//MARK: - View Controller -
@objc(ShareExtensionViewController)
final class ShareViewController: UIViewController {
    
    @IBOutlet weak var settingsView: SettingsView!
    
    @IBOutlet weak var titleIDLabel: UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var extensionView: UIView!
    
    //MARK: - Control Properties -
    @IBOutlet weak var searchToggle: UISegmentedControl!
    @IBOutlet weak var editSwitch: UISwitch!
    
    //MARK: - Initialization -
    private let alertService = AlertService.shared
    private var settingsService = SettingsService.shared
    
    private let extensionHandler = ExtensionHandler()
    private let validateURLHandler = ValidateURLHandler()
    private let tmdbHandler = TMDbHandler()
    private let radarrHandler = RadarrHandler()
    private let resultHandler = ResultHandler()
    
    // MARK: - Main -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
        // Initial setup
        registerGesture()
        setupViewSettings()
        
    }
    
    func startChainReaction() throws {
        
        guard let url = try extensionHandler.handleShare(context: self.extensionContext!) else {
            throw ExtensionError.general
        }
        
        guard let imdbId = try validateURLHandler.returnIMDbId(from: url) else {
            throw UrlError.general
        }
        
        guard let movieData = try tmdbHandler.fetchMovieData(IMDbId: imdbId) else {
            throw TMDbError.general
        }
        
        guard let result = try radarrHandler.sendMovieToRadarr(movie: movieData) else {
            throw RadarrError.general
        }
        
        do {
            try resultHandler.validateRadarrResponse(with: result)
        } catch {
            throw error
        }

        
    }
   
    //MARK: - Handle buttons / controls -
    
    // Save Search Now preference when segmented control is changed
    // Call settings.save() to save to UserDefaults
    // Call Zephyr.sync to sync selected UserDefaults to iCloud
    @IBAction private func searchSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        if selectedSegment == 0 {
            settingsService.searchNow = true
        } else {
            settingsService.searchNow = false
        }
        
        // Save UserDefaults data
        settingsService.save()

    }
    
    @IBAction private func editSwitchPressed(_ sender: UISwitch) {
        
        if sender.isOn {
         
            registerKeyboardObservers()
            expandSettingsView()
            
        } else {
            
            view.endEditing(true)
            collapseSettingsView()
            removeKeyboardObservers()
        }
    }
    
    // Dismiss share sheet when "Cancel" button pressed
    @IBAction private func cancelButtonPressed(_ sender: UIButton) {
        
        self.extensionContext!.completeRequest(
            returningItems: [],
            completionHandler: nil
        )
    }
    
    // Check for empty settings fields before sending movie to Radarr server
    @IBAction private func sendButtonPressed(_ sender: UIButton) {
        
        if settingsService.settingsAreIncomplete()
        {
            self.alertService.displayErrorUIAlertController(
                sender: self,
                title: "Error",
                message: "All settings fields must be filled out",
                dismissShareSheet: false
            )
        } else {
            
            let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
            dispatchQueue.async{
                         
                 do {
                    try self.startChainReaction()
                    
                    self.alertService.displayUIAlertController(
                        sender: self,
                        title: "Done",
                        message: "Movie sent to Radarr!")
                    
                 } catch {
                     print(error.localizedDescription)
                     
                     self.alertService.displayErrorUIAlertController(
                         sender: self,
                         title: "Error",
                         message: error.localizedDescription,
                         dismissShareSheet: false)
                 }
            }
        }
        
    }
    
    // MARK: - Setup Functions -
    
    fileprivate func setupViewSettings() {
        
        // Set search toggle state
        if settingsService.searchNow {
            searchToggle.selectedSegmentIndex = 0
        } else {
            searchToggle.selectedSegmentIndex = 1
        }
        
        // Round top corners
        extensionView.layer.cornerRadius = CGFloat(8)
        extensionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        extensionView.clipsToBounds = true
        
        // Settings panel initially closed
        viewHeight.constant = 240
        settingsView.isHidden = true

    }
    
    fileprivate func registerGesture() {
        
        // Keyboard dismissal gesture
        let tap = UITapGestureRecognizer(
            target: self.view,
            action: #selector(UIView.endEditing)
        )
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Handle Keyboard -
        
    // Move text fields up when keyboard appears
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? NSValue)?.cgRectValue
            else {
                return
        }
        
        // move the root view up by the distance of keyboard height
        self.view.frame.origin.y = 0 - keyboardSize.height
        //        print(keyboardSize.height)
    }
    
    // Auto save user text from text fields into Settings model when keyboard is dismissed
    // Call settings.save() to save to UserDefaults
    @objc private func keyboardWillHide(notification: NSNotification) {
        
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
        
        // Store user settings
        self.storeUserSettings()
        
        // Save UserDefaults data
        settingsService.save()
        
    }
    
    fileprivate func registerKeyboardObservers() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    fileprivate func removeKeyboardObservers() {
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    fileprivate func storeUserSettings() {
        
        settingsService.radarrServerAddress = settingsView.serverAddressField.text!
        settingsService.radarrServerPort = Int(settingsView.serverPortField.text!)!
        settingsService.radarrAPIKey = settingsView.radarrAPIKeyField.text!
        settingsService.rootFolderPath = settingsView.rootFolderPathField.text!
        settingsService.tmdbAPIKey = settingsView.tmdbAPIKeyField.text!
     }
}
