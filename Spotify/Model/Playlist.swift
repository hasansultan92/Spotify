//
//  Playlist.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/6/23.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [ApiImage]
    let name: String
    let owner: User
}
