//
//  Movie.swift
//  MovieExplorer
//
//  Created by Maksim Li on 19/08/2025.
//

import Foundation

struct Movie {
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
    
    var releaseYear: String {
        String(releaseDate.prefix(4))
    }
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var fullBackdropPath: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "https://image.tmdb.org/t/p/w1280\(backdropPath)"
    }
}
