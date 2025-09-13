//
//  MovieResponse.swift
//  MovieExplorer
//
//  Created by Maksim Li on 07/09/2025.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
    let page: Int
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results, page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
