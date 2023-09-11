//
//  AuthResponse.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/9/23.
//

import Foundation

struct AuthResponse: Codable{
    let access_token: String
    let expires_in:Int
    let refresh_token : String?
    let scopre: String
    let token_type: String
}
