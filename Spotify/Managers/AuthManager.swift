//
//  AuthManager.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/6/23.
//

import Foundation


// Object
final class AuthManager {
    static let shared = AuthManager()
    
    struct Constant {
        static let ClientId  = "6fba618119134925a35d03e66ee39363"
        static let ClientSecret = "9d3b8d85dc9d42d0a1e98c9520092846"
        
    }
    
    private init(){}
    
    public var signInURL: URL? {
        let scopes = "user-read-private"
        let redirectUri = "https://www.iosacademy.io"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constant.ClientId)&scope=\(scopes)&redirect_uri=\(redirectUri)&show_dialog=TRUE"
    return URL(string: string )
    }
    
    var isSignedIn : Bool{
        return false
    }
    
    private var AccessToken: String?{
        return nil
    }
    
    private var refreshToken: String?{
        return nil
    }
    
    private var tokenExpirationDate: Date?{
        return nil
    }
    
    private var shouldRefreshToken: Bool{
        return false
    }
    
    public func exchangeCodeForToken(
    code:String,
    completion :@escaping (Bool)->Void)
    {
        // Get token
    }
    
    private func refreshAccessToken (){
        
    }
    
    private func cacheToken(){
        
    }
}
