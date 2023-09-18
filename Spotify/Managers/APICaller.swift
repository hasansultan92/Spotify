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
    
    public func getFeaturedPlaylists (completion: @escaping ((Result<FeaturedPlaylistResponse, Error>)->Void)){
        
        createRequest(with: URL(string: Constants.baseURL + "/browse/featured-playlists?limits=2"), type: .GET){
            request in
            
            let task = URLSession.shared.dataTask(with: request)
            {
                data, HTTPResponse, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    print(result)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationsGenres(completion:@escaping((Result<RecommendedGenresResponse, Error>)->Void)){
        createRequest(with: URL(string: Constants.baseURL + "/recommendations/available-genre-seeds"), type: .GET){
            request in
            let task = URLSession.shared.dataTask(with: request)
            {
                data, HTTPResponse, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommended(genres: Set<String>, completion: @escaping ((Result<RecommendationResponse, Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseURL + "/recommendations?limit=10&seed_genres=\(seeds)"),
            type: .GET)
        {
            request in
            let task = URLSession.shared.dataTask(with: request)
            {
                data, HTTPResponse, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}


enum HTTPMethod : String {
    case GET
    case POST
}

// MARK: Create Request
private func createRequest
(
    with url:URL?,
    type: HTTPMethod,
    completion: @escaping (URLRequest)->Void
)
{
    AuthManager.shared.withValidToken {
        token in // should return the string of the token
        guard let apiURL = url else{
            return
        }
        var request = URLRequest(url: apiURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = type.rawValue
        request.timeoutInterval = 30
        completion(request)
    }
}


