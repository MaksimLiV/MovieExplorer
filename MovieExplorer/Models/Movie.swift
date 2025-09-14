//
//  Movie.swift
//  MovieExplorer
//
//  Created by Maksim Li on 19/08/2025.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let originalLanguage: String
    let adult: Bool
    let video: Bool
    let genreIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult, video, popularity
        case originalTitle = "original_title"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
    }
    var releaseYear: String {
        String(releaseDate.prefix(4))
        
    }
    
    var fullPosterURL: String? {
        
        guard let posterPath = posterPath else { return nil }
        return "\(APIKey.tmdbImageBaseURL)/w500\(posterPath)"
    }
    
    var fullBackdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "\(APIKey.tmdbImageBaseURL)/w1280\(backdropPath)"
    }
}
