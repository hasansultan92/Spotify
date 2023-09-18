//
//  RecommendationsResponse.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/17/23.
//

import Foundation

struct RecommendationResponse: Codable {
    let tracks: [AudioTrack]
}
