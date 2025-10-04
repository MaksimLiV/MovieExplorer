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
    private func buildSearchURL(query: String, page: Int = 1, year: Int? = nil) -> URL? {
        
        let fullBaseURL = "\(APIKey.tmdbBaseURL)/search/movie"
        var components = URLComponents(string: fullBaseURL)
        
        var queryItems = [
            URLQueryItem(name: "api_key", value: APIKey.tmdbAPIKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let year = year {
            queryItems.append(URLQueryItem(name: "primary_release_year", value: "\(year)"))
        }
        
        components?.queryItems = queryItems
        
        if let finalURL = components?.url {
            return finalURL
        } else {
            print("ERROR: Failed to create search URL from components")
            return nil
        }
    }
    
    func searchMovies(query: String, page: Int = 1, year: Int? = nil, completion: @escaping(Result<MovieResponse, Error>) -> Void) {
        
        guard let url = buildSearchURL(query: query, page: page, year: year) else {
            print("ERROR: Failed to create search URL")
            completion(.failure(NetworkError.inValidURL))
            return
        }
        
        performRequest(url: url, requestType: "SEARCH", completion: completion)
    }
    
    // MARK: - Discover Movies
    private func buildDiscoverURL(page: Int = 1, year: Int) -> URL? {
        let discoverURL = "\(APIKey.tmdbBaseURL)/discover/movie"
        var components = URLComponents(string: discoverURL)
        
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: APIKey.tmdbAPIKey),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "primary_release_year", value: "\(year)"),
            URLQueryItem(name: "sort_by", value: "vote_average.desc"),
            URLQueryItem(name: "vote_count.gte", value: "10")
        ]
        
        if let finalURL = components?.url {
            return finalURL
        } else {
            print("ERROR: Failed to create discover URL")
            return nil
        }
    }
    
    func getMoviesForYear(year: Int, page: Int = 1, completion: @escaping(Result<MovieResponse, Error>) -> Void) {
        
        guard let url = buildDiscoverURL(page: page, year: year) else {
            print("ERROR: Failed to create discover URL")
            completion(.failure(NetworkError.inValidURL))
            return
        }
        
        performRequest(url: url, requestType: "DISCOVER", completion: completion)
    }
    
    // MARK: - Legacy Trending Movies 
    private func buildTrendingURL() -> URL? {
        let trendingURL = "\(APIKey.tmdbBaseURL)/trending/movie/day"
        var components = URLComponents(string: trendingURL)
        
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: APIKey.tmdbAPIKey)
        ]
        
        if let finalURL = components?.url {
            return finalURL
        } else {
            print("ERROR: Failed to create trending URL")
            return nil
        }
    }
    
    func getTrendingMovies(completion: @escaping(Result<MovieResponse, Error>) -> Void) {
        
        guard let url = buildTrendingURL() else {
            print("ERROR: Failed to create trending URL")
            completion(.failure(NetworkError.inValidURL))
            return
        }
        
        performRequest(url: url, requestType: "TRENDING", completion: completion)
    }
    
    // MARK: - Common Request Handler
    private func performRequest(url: URL, requestType: String, completion: @escaping(Result<MovieResponse, Error>) -> Void) {
        
        self.urlSession.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("\(requestType) NETWORK ERROR: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
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
            
            do {
                let movieResponse = try self.jsonDecoder.decode(MovieResponse.self, from: data)
                completion(.success(movieResponse))
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
