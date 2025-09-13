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
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search movies..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let networkService = NetworkService()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchAndTable()
        setupNavigationButtons()
        
        title = "Movie Search"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Movie Search", style: .plain, target: nil, action: nil)
        
        loadTrendingMovies()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearchAndTable() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 110
        searchBar.delegate = self
    }
    
    private func setupNavigationButtons() {
        let aboutButton = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(aboutTapped))
        navigationItem.leftBarButtonItem = aboutButton
        
        let favoritesButton = UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(favoritesTapped))
        navigationItem.rightBarButtonItem = favoritesButton
    }
    
    @objc private func aboutTapped() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @objc private func favoritesTapped() {
        let favoritesVC = FavoritesViewController()
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    private func loadTrendingMovies() {
        print("Loading trending movies...")
        activityIndicator.startAnimating()
        
        networkService.getTrendingMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.tableView.reloadData()
                    print("Loaded \(movies.count) trending movies")
                case .failure(let error):
                    print("Failed to load trending movies: \(error)")
                }
            }
        }
    }
    
    private func searchMovies(query: String) {
        print("Searching movies: \(query)")
        activityIndicator.startAnimating()
        
        networkService.searchMovies(query: query) {
            [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.tableView.reloadData()
                    print("Found \(movies.count) movies for query: \(query)")
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMovie = movies[indexPath.row]
        let detailVC = DetailViewController(movie: selectedMovie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        searchMovies(query: query)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadTrendingMovies()
        }
    }
}
