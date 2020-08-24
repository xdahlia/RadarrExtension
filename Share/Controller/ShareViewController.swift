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
class ShareViewController: UIViewController {
    
    @IBOutlet weak var titleIDLabel: UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var extensionView: UIView!
    
    //MARK: - Control Properties -
    @IBOutlet weak var searchToggle: UISegmentedControl!
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var editSwitch: UISwitch!
    
    //MARK: - Settings Properties -
    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var radarrAPIKeyField: UITextField!
    @IBOutlet weak var rootFolderPathField: UITextField!
    @IBOutlet weak var tmdbAPIKeyField: UITextField!
    
    //MARK: - Initialization -
    var tmdbService = TMDBService.shared
    var radarrService = RadarrService.shared
    var alertService = AlertService.shared
    var radarr = Radarr()
    var settings = Settings()
    
    fileprivate func setSettingsTextFieldContent() {
        // Populate settings text fields with data from Settings model
        serverAddressField.text = settings.radarrServerAddress
        radarrAPIKeyField.text = settings.radarrAPIKey
        rootFolderPathField.text = settings.rootFolderPath
        tmdbAPIKeyField.text = settings.tmdbAPIKey
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
    
    fileprivate func setupViewSettings() {
        // Set search toggle state
        if settings.searchNow {
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
        settingsStack.isHidden = true
    }
    
    fileprivate func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
        // Load UserDefaults data
        settings.load()
        
        setSettingsTextFieldContent()
        setSettingsTextFieldDelegates()
        
        setSettingsTextFieldContentTypes()
        
        setupViewSettings()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        // Make reference to itself available to RadarrService and TMDBService
        radarrService.viewController = self
        tmdbService.viewController = self

        self.handleSharedFile()
    }
    
    //MARK: - Core Functionality -
    
    // Take shared IMDB url and call "extractIDFromIMDBUrl"
    private func handleSharedFile() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            item.attachments?.forEach({ (attachment) in
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? NSURL {
                            
                            // Dismiss share sheet if not from IMDB movie page
                            if let domain = shareURL.host {
                                if domain != "www.imdb.com" {
                                    self.alertService.displayErrorUIAlertController(sender: self, title: "Error", message: "You must share from either IMDB app or website", dismissShareSheet: true)
                                } else {
                                    // Extract IMDB movie ID
                                    self.settings.imdbID = self.extractIDFromIMDBUrl(url: shareURL)
                                    
                                    // Send movie id to TMDBService as soon as possible
                                    self.tmdbService.tmdbAPIKey = self.settings.tmdbAPIKey
                                    self.tmdbService.ImdbId = self.settings.imdbID
                                    
                                    // Method sendMovieToRadarr() is triggered once user activates sendButtonPressed() method
                                }
                            }
                        }
                        
                        if let error = error {
                            self.alertService.displayErrorUIAlertController(sender: self, title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                        }
                    })
                }
            })
        }
    }
    
    // Extract movie data from TMDB, fill Radarr model with movie data, call "postURL" with data
    func sendMovieToRadarr() {
        
        // Fill Radarr model with user settings and movie data
        self.radarr.monitored = settings.searchNow
        self.radarr.addOptions.searchForMovie = settings.searchNow
        self.radarr.title = tmdbService.title
        self.radarr.tmdbId = tmdbService.TmdbId
        self.radarr.year = tmdbService.release_date
        if let titleSlug = tmdbService.title.convertedToSlug() {
            self.radarr.titleSlug = "\(titleSlug)-\(tmdbService.TmdbId)"
        }
        self.radarr.images[0].url = "https://image.tmdb.org/t/p/w1280\(tmdbService.poster_path)"
        self.radarr.rootFolderPath = self.settings.rootFolderPath
        
        // Construct JSON from Radarr model
        if let radarrJSON = radarrService.radarrToJSON(data: self.radarr) {
            // Post JSON to Radarr server
            radarrService.postJSON(from: radarrJSON, url: settings.urlString)
        }
        
    }
    
    //MARK: - Handle Keyboard -
    
    // Move text fields up when keyboard appears
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        // move the root view up by the distance of keyboard height
        self.view.frame.origin.y = 0 - keyboardSize.height
        print(keyboardSize.height)
    }
    
    // Auto save user text from text fields into Settings model when keyboard is dismissed
    // Call settings.save() to save to UserDefaults
    // Call Zephyr.sync to sync selected UserDefaults to iCloud
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    
        // Store user settings
        settings.radarrServerAddress = serverAddressField.text!
        settings.radarrAPIKey = radarrAPIKeyField.text!
        settings.rootFolderPath = rootFolderPathField.text!
        settings.tmdbAPIKey = tmdbAPIKeyField.text!
        settings.urlString = "\(settings.radarrServerAddress)/api/movie?apikey=\(settings.radarrAPIKey)"
        
        // Save UserDefaults data
        settings.save()

    }
    
    //MARK: - Handle buttons / controls -
    
    // Save Search Now preference when segmented control is changed
    // Call settings.save() to save to UserDefaults
    // Call Zephyr.sync to sync selected UserDefaults to iCloud
    @IBAction func searchSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        if selectedSegment == 0 {
            settings.searchNow = true
        } else {
            settings.searchNow = false
        }
        
        // Save UserDefaults data
        settings.save()
        
    }
    
    // Expand / collapse settings fields when "Edit Settings" toggled
    @IBAction func editSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            registerKeyboardObservers()
            viewHeight.constant = 490
            settingsStack.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.endEditing(true)
            settingsStack.isHidden = true
            viewHeight.constant = 240
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            removeKeyboardObservers()
        }
    }
    
    // Dismiss share sheet when "Cancel" button pressed
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    // Check for empty settings fields before sending movie to Radarr server
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        if serverAddressField.text! == "" || radarrAPIKeyField.text! == "" || rootFolderPathField.text! == "" || tmdbAPIKeyField.text! == "" {
            self.alertService.displayErrorUIAlertController(sender: self, title: "Error", message: "All settings fields must be filled out", dismissShareSheet: false)
        } else {
            self.sendMovieToRadarr()
        }
        
    }
    
    //MARK: - Utility Functions -
    
    // Extract IMDB title id from url
    func extractIDFromIMDBUrl(url: NSURL) -> String {
        
        if let url = url.absoluteString {
            var replaced = url.replacingOccurrences(of: "https://www.imdb.com/title/", with: "")
            replaced = replaced.replacingOccurrences(of: "/", with: "")
            return replaced
        } else {
            self.alertService.displayErrorUIAlertController(sender: self, title: "Error", message: "Error extracting IMDB ID from url", dismissShareSheet: false)
            return "Error extracting IMDB ID from url"
        }
    }
}

//MARK: - Extensions -

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

// Converts string "movie title's string" to slug "movie-title-s-string"
// From Hacking With Swift
extension String {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")
    
    public func convertedToSlug() -> String? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
            let result = urlComponents.filter { $0 != "" }.joined(separator: "-")
            
            if result.count > 0 {
                return result
            }
        }
        
        return nil
    }
}
