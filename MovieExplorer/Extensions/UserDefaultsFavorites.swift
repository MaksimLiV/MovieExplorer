//
//  UserDefaults+Favorites.swift
//  MovieExplorer
//
//  Created by Maksim Li on 11/09/2025.
//

import Foundation

extension UserDefaults {
    
    private enum Keys {
        static let favoriteMovies = "FavoriteMovies"
    }
    
    func getFavoriteMovies() -> [Movie] {
        guard let data = data(forKey: Keys.favoriteMovies) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([Movie].self, from: data)) ?? []
    }
    
    func saveFavoriteMovies(_ movies: [Movie]) {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(movies) else {
            print("Failed to encode favorite movies")
            return
        }
        set(encoded, forKey: Keys.favoriteMovies)
    }
    
    func isFavorite(_ movie: Movie) -> Bool {
        let favorites = getFavoriteMovies()
        return favorites.contains { $0.id == movie.id }
    }
    
    func addToFavorites(_ movie: Movie) {
        var favorites = getFavoriteMovies()
        
        guard !favorites.contains(where: { $0.id == movie.id }) else {
            print("Movie \(movie.title) is already in favorites")
            return
        }
        
        favorites.append(movie)
        saveFavoriteMovies(favorites)
        print("Added \(movie.title) to favorites")
    }
    
    func removeFromFavorites(_ movie: Movie) {
        var favorites = getFavoriteMovies()
        favorites.removeAll { $0.id == movie.id }
        saveFavoriteMovies(favorites)
        print("Removed \(movie.title) from favorites")
    }
    
    func toggleFavorite(_ movie: Movie) {
        if isFavorite(movie) {
            removeFromFavorites(movie)
        } else {
            addToFavorites(movie)
        }
    }
}
