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
        static let base = "https://www.accounts.spotify.com/authorize"
        static let ClientId  = "6fba618119134925a35d03e66ee39363"
        static let ClientSecret = "9d3b8d85dc9d42d0a1e98c9520092846"
        static let tokenApiURL = "https://accounts.spotify.com/api/token"
        static let redirectUri = "https://www.google.com"
        //static let scopes = "user-read-private"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init(){}
    
    public var signInURL: URL? {
       
        let string = "\(Constant.base)?response_type=code&client_id=\(Constant.ClientId)&scope=\(Constant.scopes)&redirect_uri=\(Constant.redirectUri)&show_dialog=TRUE"
    return URL(string: string )
    }
    
    var isSignedIn : Bool{
        return AccessToken != nil
    }
    
    private var AccessToken: String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool{
        guard let expirationDate = tokenExpirationDate else{
            return false
        }
        let currentDate = Date() //Includes the time
        let fiveMinutes: TimeInterval = 300 // Five minutes
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(
    code:String,
    completion :@escaping (Bool)->Void)
    {
        //MARK: - Auth logic
        guard let url = URL(string: Constant.tokenApiURL) else {
            return
        }
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "authorization_code"),
        URLQueryItem(name: "code", value: code),
        URLQueryItem(name: "redirect_uri", value: Constant.redirectUri)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        request.httpBody =  components.query?.data(using: .utf8)
        

        let basicToken = Constant.ClientId+":"+Constant.ClientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base64")
            completion(false)
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){[weak self] data, _, error in
            guard let data = data,
                    error == nil else{
                completion(false)
                return
            }
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print("Success \(json)")
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                //print(result)
                self?.cacheToken(result:result)
                completion(true)
            } catch {
                // Something went wrong
                print("Facing an error here")
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    
    public func refreshIfNeeded (completion:((Bool)->Void)?) {

        guard !shouldRefreshToken else{
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {return}

        //MARK: - Refresh logic
        
        guard let url = URL(string: Constant.tokenApiURL)else{
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "refresh_token"),
        URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody =  components.query?.data(using: .utf8)
        
        let basicToken = Constant.ClientId+":"+Constant.ClientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base64 in refreshToken")
            completion?(false)
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){[weak self] data, _, error in
            guard let data = data,
                    error == nil else{
                completion?(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                //print("successfully refreshed")
                self?.cacheToken(result:result)
                completion?(true)
            } catch {
                print("Something is going wrong")
                print(error.localizedDescription)
                completion?(false) // Something failed
            }
        }
        task.resume()
        
    }
    
    // Attempts to cache the token if there was a change coming from the Spotify URL
    private func cacheToken(result:AuthResponse){
        //print(result)
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token{
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationData")
    }
}
