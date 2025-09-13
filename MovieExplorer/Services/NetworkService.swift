//
//  NetworkService.swift
//  MovieExplorer
//
//  Created by Maksim Li on 07/09/2025.
//

import Foundation

class NetworkService {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init() {
        self.urlSession = URLSession.shared
        self.jsonDecoder = JSONDecoder()
    }
    
    // MARK: - Search Movies
    private func buildSearchURL(query: String) -> URL? {
        print("--- Building Search URL ---")
        print("Base URL: \(APIKey.tmdbBaseURL)")
        print("API Key: \(APIKey.tmdbAPIKey)")
        print("Search query: '\(query)'")
        
        // Create full base URL including API version
        let fullBaseURL = "\(APIKey.tmdbBaseURL)/search/movie"
        var components = URLComponents(string: fullBaseURL)
        
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: APIKey.tmdbAPIKey),
            URLQueryItem(name: "query", value: query)
        ]
        
        if let finalURL = components?.url {
            print("Final Search URL: \(finalURL.absoluteString)")
            return finalURL
        } else {
            print("ERROR: Failed to create search URL from components")
            return nil
        }
    }
    
    func searchMovies(query: String, completion: @escaping(Result<[Movie], Error>) -> Void) {
        print("=== STARTING SEARCH REQUEST ===")
        print("Query: '\(query)'")
        
        guard let url = buildSearchURL(query: query) else {
            print("ERROR: Failed to create search URL")
            completion(.failure(NetworkError.inValidURL))
            return
        }
        
        performRequest(url: url, requestType: "SEARCH", completion: completion)
    }
    
    // MARK: - Trending Movies
    private func buildTrendingURL() -> URL? {
        print("--- Building Trending URL ---")
        let trendingURL = "\(APIKey.tmdbBaseURL)/trending/movie/day"
        var components = URLComponents(string: trendingURL)
        
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: APIKey.tmdbAPIKey)
        ]
        
        if let finalURL = components?.url {
            print("Final Trending URL: \(finalURL.absoluteString)")
            return finalURL
        } else {
            print("ERROR: Failed to create trending URL")
            return nil
        }
    }
    
    func getTrendingMovies(completion: @escaping(Result<[Movie], Error>) -> Void) {
        print("=== STARTING TRENDING REQUEST ===")
        
        guard let url = buildTrendingURL() else {
            print("ERROR: Failed to create trending URL")
            completion(.failure(NetworkError.inValidURL))
            return
        }
        
        performRequest(url: url, requestType: "TRENDING", completion: completion)
    }
    
    // MARK: - Common Request Handler
    private func performRequest(url: URL, requestType: String, completion: @escaping(Result<[Movie], Error>) -> Void) {
        print("Performing \(requestType) request to: \(url.absoluteString)")
        
        self.urlSession.dataTask(with: url) { data, response, error in
            print("=== RECEIVED \(requestType) RESPONSE ===")
            
            if let error = error {
                print("\(requestType) NETWORK ERROR: \(error)")
                print("Error code: \((error as NSError).code)")
                print("Error domain: \((error as NSError).domain)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("\(requestType) HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Server returned non-200 status code for \(requestType)")
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                print("ERROR: No data received for \(requestType)")
                completion(.failure(NetworkError.noData))
                return
            }
            
            print("\(requestType) received data: \(data.count) bytes")
            
            do {
                let movieResponse = try self.jsonDecoder.decode(MovieResponse.self, from: data)
                print("Successfully decoded \(movieResponse.results.count) movies for \(requestType)")
                completion(.success(movieResponse.results))
            } catch {
                print("\(requestType) DECODING ERROR: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON Response: \(jsonString.prefix(500))...")
                }
                completion(.failure(NetworkError.decoderError))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case inValidURL
    case noData
    case decoderError
    case serverError(Int)
}
