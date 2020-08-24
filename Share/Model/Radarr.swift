//
//  Radarr.swift
//  Share
//
//  Created by Ivan Ou on 7/29/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

struct Radarr: Codable {
    
    var title: String = ""
    var qualityProfileId: Int = 4
    var tmdbId: Int = 0
    var titleSlug: String = ""
    var monitored: Bool = false
    var minimumAvailability: String = "released"
    var profileId: Int = 4
    var year: Int = 0
    var rootFolderPath: String = ""
    var addOptions: Option = Option()
    var images: Array<Image> = [Image(url: "")]
    
    struct Option: Codable {
        var searchForMovie: Bool = false
    }

    struct Image: Codable {
        var covertype: String = "poster"
        var url: String = ""
    }

}
