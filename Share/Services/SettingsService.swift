//
//  Settings.swift
//  Share
//
//  Created by Ivan Ou on 8/10/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import KeychainAccess
import Zephyr

class SettingsService {
    
    static let shared = SettingsService()

    let defaults = UserDefaults.standard
    let keychain = Keychain(service: "com.ivanou.RadarrExtension")
    
    var imdbID: String = ""
    var radarrServerAddress: String = ""
    var radarrAPIKey: String = ""
    var rootFolderPath: String = ""
    var urlString: String = ""
    var searchNow: Bool = false
    var tmdbAPIKey: String = ""
    
    func save() {
        
        // Save into Keychain
        keychain["serverAddress"] = radarrServerAddress
        keychain["radarAPIKey"] = radarrAPIKey
        keychain["rootFolderPath"] = rootFolderPath
        keychain["tmdbAPIKey"] = tmdbAPIKey
        
        // Save UserDefaults
//        defaults.setValue(radarrServerAddress, forKey: "serverAddress")
//        defaults.setValue(rootFolderPath, forKey: "rootFolderPath")
        defaults.setValue(searchNow, forKey: "searchNow")
//
//        // Sync UserDefaults with iCloud
//        Zephyr.debugEnabled = true
//        Zephyr.sync(keys: ["serverAddress", "rootFolderPath", "searchNow"])
        
    }
    
    func load() {
        
        // Load from Keychain
        radarrAPIKey = keychain["radarAPIKey"] ?? ""
        radarrServerAddress = keychain["serverAddress"] ?? ""
        rootFolderPath = keychain["rootFolderPath"] ?? ""
        tmdbAPIKey = keychain["tmdbAPIKey"] ?? ""
        
        // Sync UserDefaults with iCloud
//        Zephyr.debugEnabled = true
//        Zephyr.sync(keys: ["serverAddress", "rootFolderPath", "searchNow"])
//
//        // Load UserDefaults
//        radarrServerAddress = defaults.string(forKey: "serverAddress") ?? ""
//        rootFolderPath = defaults.string(forKey: "rootFolderPath") ?? ""
        searchNow = defaults.bool(forKey: "searchNow")

        // Construct Radarr URL
        urlString = "\(radarrServerAddress)/api/movie?apikey=\(radarrAPIKey)"
    }
    
    func settingsAreIncomplete() -> Bool {
        
        if radarrServerAddress.isEmpty
            || radarrAPIKey.isEmpty
            || rootFolderPath.isEmpty
            || tmdbAPIKey.isEmpty
        {
            return true
        } else {
            return false
        }
    }
    
    func TMDbAPIKeyIsSet() -> Bool {
        if tmdbAPIKey.isEmpty{
            return false
        } else {
            return true
        }
    }
    
}
