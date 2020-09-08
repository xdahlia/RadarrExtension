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
    var addOptions: Option = Option()
    var images: Array<Image> = [Image(url: "")]
    
    struct Option: Codable {
        var searchForMovie: Bool = false
    }

    struct Image: Codable {
        var covertype: String = "poster"
        var url: String = ""
    }
    
    init(
        title: String = "",
        tmdbId: Int = 0,
        titleSlug: String = "",
        monitored: Bool = false,
        year: Int = 0,
        rootFolderPath: String = "",
        searchNow: Bool = false,
        imageUrl: String = ""
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
