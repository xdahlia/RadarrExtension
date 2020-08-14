//
//  ShareViewController.swift
//  Share
//
//  Created by Ivan Ou on 7/28/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

// FIXME: -
// FIXME: Settings changes are only effective on subsequent load (done?)
// FIXME: -

// TODO: -
// TODO: Construct Radarr URL from components
// TODO: -

import UIKit
//import MobileCoreServices

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
    
    @IBOutlet weak var titleIDLabel: UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var extensionView: UIView!
    
    //MARK: - Control Properties
    @IBOutlet weak var searchToggle: UISegmentedControl!
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var editSwitch: UISwitch!
    
    //MARK: - Settings Properties
    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var radarrAPIKeyField: UITextField!
    @IBOutlet weak var rootFolderPathField: UITextField!
    
    //MARK: - Initialization
    var radarr = Radarr()
    var settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        
        settings.load()
        
        serverAddressField.text = settings.radarrServerAddress
        radarrAPIKeyField.text = settings.radarrAPIKey
        rootFolderPathField.text = settings.rootFolderPath
        
        serverAddressField.delegate = self
        radarrAPIKeyField.delegate = self
        rootFolderPathField.delegate = self
        
        if settings.searchNow {
            searchToggle.selectedSegmentIndex = 0
        } else {
            searchToggle.selectedSegmentIndex = 1
        }
        
        extensionView.layer.cornerRadius = CGFloat(8)
        extensionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        extensionView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        viewHeight.constant = 240
        settingsStack.isHidden = true
        
        self.handleSharedFile()
    }
    
    //MARK: - Handle buttons / controls
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        if serverAddressField.text! == "" || radarrAPIKeyField.text! == "" || rootFolderPathField.text! == "" {
            displayErrorUIAlertController(title: "Error", message: "All settings fields must be filled out", dismissShareSheet: false)
        } else {
            self.sendMovieToRadarrFromIMDB(id: settings.imdbID, nowOption: settings.searchNow)
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @IBAction func searchSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        if selectedSegment == 0 {
            settings.searchNow = true
        } else {
            settings.searchNow = false
        }
        
        settings.save()
        
    }
    
    @IBAction func editSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            viewHeight.constant = 430
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
        }
    }
    
    //MARK: - Handle Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        // move the root view up by the distance of keyboard height
        self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
        
        settings.radarrServerAddress = serverAddressField.text ?? ""
        settings.radarrAPIKey = radarrAPIKeyField.text ?? ""
        settings.rootFolderPath = rootFolderPathField.text ?? ""
        settings.urlString = "\(settings.radarrServerAddress)/api/movie?apikey=\(settings.radarrAPIKey)"
        
        settings.save()
    }
    
    //MARK: - Core Functionality
    
    private func handleSharedFile() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            item.attachments?.forEach({ (attachment) in
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? NSURL {
                            self.settings.imdbID = self.extractIDFromIMDBUrl(url: shareURL)
                            
                            if let domain = shareURL.host {
                                if domain != "www.imdb.com" {
                                    self.displayErrorUIAlertController(title: "Error", message: "You must share from either IMDB app or website", dismissShareSheet: true)
                                }
                            }
                            
                        }
                        if let error = error {
                            self.displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                        }
                    })
                }
            })
        }
    }
    
    func sendMovieToRadarrFromIMDB(id: String, nowOption: Bool) {
        
        // TODO: Remember to move api key before pushing to GitHub
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3/find/" + id
        components.queryItems = [
            URLQueryItem(name: "external_source", value: "imdb_id"),
            URLQueryItem(name: "api_key", value: "***REMOVED***")
        ]
        
        if let url = components.url {
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if let json = data {
                    
                    let jsonString = String(data: json, encoding: .utf8)!
                    
                    if let tmdb = self.jsonToTMDB(json: jsonString)?.movie_results[0] {
                        
                        // search options
                        self.radarr.monitored = nowOption
                        self.radarr.addOptions.searchForMovie = nowOption
                        
                        self.radarr.title = tmdb.title
                        self.radarr.tmdbId = tmdb.id
                        self.radarr.year = self.extractYearFromDate(date: tmdb.release_date)
                        
                        if let titleSlug = tmdb.title.convertedToSlug() {
                            self.radarr.titleSlug = "\(titleSlug)-\(tmdb.id)"
                        }
                        self.radarr.images[0].url = "https://image.tmdb.org/t/p/w1280\(tmdb.poster_path)"
                        self.radarr.rootFolderPath = self.settings.rootFolderPath
                        
                    }
                    
                    if let radarrJSON = self.radarrToJson(data: self.radarr) {
                        self.postURL(from: radarrJSON)
                    }
                    
                }
                
                if let error = error {
                    self.displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                }
                
            }
            task.resume()
        }
        
    }
    
    func postURL(from data: Data) {
        
        if let url = URL(string: settings.urlString) {
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.httpMethod = "POST"
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    self.displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode
                        
                        if statusCode == 400 {
                            self.displayErrorUIAlertController(title: "Error", message: "Movie already exists", dismissShareSheet: false)
                        } else if statusCode == 401 {
                            self.displayErrorUIAlertController(title: "Error", message: "The Radarr API Key may be wrong", dismissShareSheet: false)
                        } else {
                            self.displayErrorUIAlertController(title: "Error", message: "A problem ocurred sending movie to Radarr", dismissShareSheet: false)
                        }
                        
                    return
                }
                
                self.displayUIAlertController(title: "Done", message: "Movie sent to Radarr!")
                
            }
            task.resume()
            
        }
        
    }
    
    //MARK: - Utility Functions
    
    func extractIDFromIMDBUrl(url: NSURL) -> String {
        
        if let url = url.absoluteString {
            var replaced = url.replacingOccurrences(of: "https://www.imdb.com/title/", with: "")
            replaced = replaced.replacingOccurrences(of: "/", with: "")
            return replaced
        } else {
            self.displayErrorUIAlertController(title: "Error", message: "Error extracting IMDB ID from url", dismissShareSheet: false)
            return "Error extracting IMDB ID from url"
        }
        
    }
    
    func jsonToRadarr(json: String) -> Radarr? {
        
        let decoder = JSONDecoder()
        
        if let jsonData = json.data(using: .utf8) {
            
            do {
                let model = try decoder.decode(Radarr.self, from: jsonData)
                return model
                
            } catch {
                displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                return nil
                
            }
        } else {
            return nil
        }
    }
    
    func radarrToJson(data: Radarr) -> Data? {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        do {
            let json = try encoder.encode(data)
            return json
            
        } catch {
            displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
            return nil
        }
        
    }
    
    func jsonToTMDB(json: String) -> TMDB? {
        
        let decoder = JSONDecoder()
        
        if let jsonData = json.data(using: .utf8) {
            
            do {
                let model = try decoder.decode(TMDB.self, from: jsonData)
                return model
                
            } catch {
                displayErrorUIAlertController(title: "Error", message: error.localizedDescription, dismissShareSheet: false)
                return nil
                
            }
        } else {
            return nil
        }
    }
    
    func extractYearFromDate(date: String) -> Int {
        guard let int = Int(String(date.prefix(4))) else { return 0 }
        return int
        
    }
    
    //MARK: - Display Alerts
    
    func displayUIAlertController(title: String, message: String) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            self.present(alert, animated:true, completion:{ Timer.scheduledTimer(withTimeInterval: 1, repeats:false, block: {_ in
                self.dismiss(animated: true, completion: nil)
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            })})
            
        }
        
    }
    
    func displayErrorUIAlertController(title: String, message: String, dismissShareSheet: Bool) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> () in
                
                if dismissShareSheet {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

//MARK: - Extensions

extension ShareViewController: UITextFieldDelegate {
    
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
