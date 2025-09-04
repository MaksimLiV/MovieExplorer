//
//  SearchViewController.swift
//  MovieExplorer
//
//  Created by Maksim Li on 31/08/2025.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    private var movies: [Movie] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadTestData()
        
        title = "Movie Search"
        
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 110
    }
    
    private func loadTestData() {
        movies = [
            Movie(
                id: 1,
                title: "Avengers: Endgame",
                originalTitle: "Avengers: Endgame",
                overview: "After the devastating events of Avengers: Infinity War, the universe is in ruins.",
                releaseDate: "2019-04-26",
                posterPath: "movie_poster_1",
                backdropPath: nil,
                voteAverage: 8.4,
                voteCount: 15234,
                popularity: 120.5,
                originalLanguage: "en",
                adult: false,
                video: false,
                genreIds: [28, 12, 878]
            ),
            Movie(
                id: 2,
                title: "Spider-Man: No Way Home",
                originalTitle: "Spider-Man: No Way Home",
                overview: "Peter Parker's secret identity is revealed to the entire world.",
                releaseDate: "2021-12-17",
                posterPath: "movie_poster_2",
                backdropPath: nil,
                voteAverage: 8.2,
                voteCount: 12567,
                popularity: 95.3,
                originalLanguage: "en",
                adult: false,
                video: false,
                genreIds: [28, 12, 878]
            )
        ]
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
}
