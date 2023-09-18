//
//  Artist.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/6/23.
//

import Foundation

struct Artist: Codable{
    let external_urls: [String:String]
    let id: String
    let name: String
    let type: String
}
