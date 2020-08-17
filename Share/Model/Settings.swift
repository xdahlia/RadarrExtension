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

struct Settings {
    
    let defaults = UserDefaults.standard
    let keychain = Keychain(service: "com.ivanou.RadarrExtension")
    
    var imdbID: String = ""
    var radarrServerAddress: String = ""
    var radarrAPIKey: String = ""
    var rootFolderPath: String = ""
    var urlString: String = ""
    var searchNow: Bool = false
    
    func save() {
        // Save UserDefaults
        defaults.setValue(radarrServerAddress, forKey: "serverAddress")
        defaults.setValue(rootFolderPath, forKey: "rootFolderPath")
        defaults.setValue(searchNow, forKey: "searchNow")
        
        // Sync UserDefaults with iCloud
        Zephyr.debugEnabled = true
        Zephyr.sync(keys: ["serverAddress", "rootFolderPath", "searchNow"])
        
        // Save into Keychain
        keychain["radarAPIKey"] = radarrAPIKey
    }
    
    mutating func load() {
        
        // Sync UserDefaults with iCloud
        Zephyr.debugEnabled = true
        Zephyr.sync(keys: ["serverAddress", "rootFolderPath", "searchNow"])
        
        // Load UserDefaults
        radarrServerAddress = defaults.string(forKey: "serverAddress") ?? ""
        rootFolderPath = defaults.string(forKey: "rootFolderPath") ?? ""
        searchNow = defaults.bool(forKey: "searchNow")
        
        // Load from Keychain
        radarrAPIKey = keychain["radarAPIKey"] ?? ""
        
        // Construct Radarr URL
        urlString = "\(radarrServerAddress)/api/movie?apikey=\(radarrAPIKey)"
    }
    
}
