//
//  Settings.swift
//  Share
//
//  Created by Ivan Ou on 8/10/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct Settings {
    
    let defaults = UserDefaults.standard
    
    var imdbID: String = ""
    var radarrServerAddress: String = ""
    var radarrAPIKey: String = ""
    var rootFolderPath: String = ""
    var urlString: String = ""
    var searchNow: Bool = false
    
    func save() {
        defaults.setValue(radarrServerAddress, forKey: "serverAddress")
        defaults.setValue(radarrAPIKey, forKey: "radarAPIKey")
        defaults.setValue(rootFolderPath, forKey: "rootFolderPath")
        defaults.setValue(searchNow, forKey: "searchNow")
    }
    
    mutating func load() {
        radarrServerAddress = defaults.string(forKey: "serverAddress") ?? ""
        radarrAPIKey = defaults.string(forKey: "radarAPIKey") ?? ""
        urlString = "\(radarrServerAddress)/api/movie?apikey=\(radarrAPIKey)"
        rootFolderPath = defaults.string(forKey: "rootFolderPath") ?? ""
        searchNow = defaults.bool(forKey: "searchNow")
    }
    
}
