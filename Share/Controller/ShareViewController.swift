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
    private let tmdbService = TMDBService.shared
    private let radarrService = RadarrService.shared
    private let alertService = AlertService.shared
    private let validationService = ValidationService.shared
    private var settingsService = SettingsService.shared
    private var radarr = Radarr()
    
    private let extensionHandler = ExtensionHandler.shared
    private let validateURLHandler = ValidateURLHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
        // Initial setup
        registerGesture()
        setupViewSettings()
        
        // Make reference to itself available to RadarrService and TMDBService
        radarrService.viewController = self
        tmdbService.viewController = self
        
//        let extractedURL = Result { try extensionHandler.handle(input: extensionContext) }

//        self.handleSharedFile()
        extensionHandler.handle(input: extensionContext) { (result) in
            switch result {
            case .success(let shareURL):
//                return urlResponse
                print(shareURL)
                
                let imdbId = Result { try self.validateURLHandler.returnIMDbId(from: shareURL) }
                print(imdbId)
                
                break // Handle response
            case .failure(let error):
                print(error.localizedDescription)
                break // Handle error
            }
        }
        
    }
    
    //MARK: - Core Functionality -
    
    // Take shared IMDb url, extract id, send to TMDb model
    private func handleSharedFile() {
        
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            item.attachments?.forEach({ (attachment) in
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    
                    attachment.loadItem(
                        forTypeIdentifier: "public.url",
                        options: nil,
                        completionHandler: { (url, error) -> Void in
                            
                            if let shareURL = url as? NSURL {
                                do {
                                    try self.validationService.validateSharedURL(with: shareURL)

                                    self.settingsService.imdbID = shareURL.pathComponents![2]
                                    // Send movie id to TMDBService as soon as possible
                                    self.tmdbService.tmdbAPIKey = self.settingsService.tmdbAPIKey
                                    self.tmdbService.ImdbId = self.settingsService.imdbID
                                    
                                } catch {
                                    
                                    self.alertService.displayErrorUIAlertController(
                                        sender: self,
                                        title: "Error",
                                        message: error.localizedDescription,
                                        dismissShareSheet: true
                                    )
                                }
                                // Method sendMovieToRadarr() is triggered once user activates sendButtonPressed() method
                            }
                            
                            if let error = error {
                                
                                self.alertService.displayErrorUIAlertController(
                                    sender: self,
                                    title: "Error",
                                    message: error.localizedDescription,
                                    dismissShareSheet: false
                                )
                            }
                    })
                }
            })
        }
    }
    
    // Extract movie data from TMDB, fill Radarr model with movie data, call "postURL" with data
    private func sendMovieToRadarr() {
        
        // Fill Radarr model with user settings and movie data
        self.radarr.monitored = settingsService.searchNow
        self.radarr.addOptions.searchForMovie = settingsService.searchNow
        self.radarr.title = tmdbService.title
        self.radarr.tmdbId = tmdbService.TmdbId
        self.radarr.year = tmdbService.release_date
        if let titleSlug = tmdbService.title.convertedToSlug() {
            self.radarr.titleSlug = "\(titleSlug)-\(tmdbService.TmdbId)"
        }
        self.radarr.images[0].url = "https://image.tmdb.org/t/p/w1280\(tmdbService.poster_path)"
        self.radarr.rootFolderPath = self.settingsService.rootFolderPath
        
        // Construct JSON from Radarr model
        if let radarrJSON = radarrService.radarrToJSON(data: self.radarr) {
            
            // Post JSON to Radarr server
            radarrService.postJSON(
                from: radarrJSON,
                url: settingsService.urlString
            )
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
            self.sendMovieToRadarr()
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
        settingsService.radarrAPIKey = settingsView.radarrAPIKeyField.text!
        settingsService.rootFolderPath = settingsView.rootFolderPathField.text!
        settingsService.tmdbAPIKey = settingsView.tmdbAPIKeyField.text!
        settingsService.urlString = "\(settingsService.radarrServerAddress)/api/movie?apikey=\(settingsService.radarrAPIKey)"
    }
}
