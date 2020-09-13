//
//  Radarr.swift
//  Share
//
//  Created by Ivan Ou on 7/29/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct Radarr: Codable {
    
    var title: String
    var qualityProfileId: Int = 4
    var tmdbId: Int
    var titleSlug: String
    var monitored: Bool
    var minimumAvailability: String = "released"
    var profileId: Int = 4
    var year: Int
    var rootFolderPath: String
    var addOptions: Option = Option(searchForMovie: false)
    var images: Array<Image> = [Image(covertype: "poster", url: "")]
    
    struct Option: Codable {
        var searchForMovie: Bool
    }

    struct Image: Codable {
        var covertype: String
        var url: String
    }
    
    init(
        title: String,
        tmdbId: Int,
        titleSlug: String,
        monitored: Bool,
        year: Int,
        rootFolderPath: String,
        searchNow: Bool,
        imageUrl: String
    ) {
        self.title = title
        self.tmdbId = tmdbId
        self.titleSlug = titleSlug
        self.monitored = monitored
        self.year = year
        self.rootFolderPath = rootFolderPath
        self.addOptions = Option(searchForMovie: searchNow)
        self.images = [Image(covertype: "poster", url: imageUrl)]
    }

}
