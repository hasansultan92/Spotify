//
//  APICaller.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/6/23.
//

import Foundation

// MARK: - API CALLER
final class APICaller {
    static let shared = APICaller()
    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
    }
    enum APIError : Error {
        case failedToGetData
    }
    
    // MARK: - Current User Profile
    public func getCurrentUserProfile (completion: @escaping(Result<String, Error>)->Void){
        createRequest(with: URL(string: Constants.baseURL + "/me"), type: .GET)
        { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest)
            {data, HTTPResponse, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let task = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success("Hello this worked"))
                }catch{
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToGetData))
                }
            }
        }
    }
    
    // MARK: - New releases
    public func getNewReleases (completion: @escaping (Result<newReleasesResponses, Error>)->Void
    ){
        createRequest(
            with : URL(string : APICaller.Constants.baseURL + "/browse/new-release?limit=50"),
            type: HTTPMethod.GET,completion: {
                request in
                let task = URLSession.shared.dataTask(with: request)
                {
                    data, HTTPResponse, error in
                    guard let data = data, error == nil else{
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(newReleasesResponses.self, from: data)
                        print(result)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    )}
}


enum HTTPMethod : String {
    case GET
    case POST
}

private func createRequest
(
with url:URL?,
type: HTTPMethod,
completion: @escaping (URLRequest)->Void
)
{
    
}


