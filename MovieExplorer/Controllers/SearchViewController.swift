//
//  SearchViewController.swift
//  MovieExplorer
//
//  Created by Maksim Li on 31/08/2025.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 110
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search movies..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private let bottomLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    // MARK: - Data & State
    private var movies: [Movie] = []
    private let networkService = NetworkService()
    
    // Pagination & filtering
    private var currentPage = 1
    private var isLoadingMore = false
    private var canLoadMore = true
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    // Search state
    private var searchMode = false
    private var currentSearchQuery = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigationBar()
        loadCurrentYearMovies()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Movie Search"
        
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
    
    private func setupTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Movie Search", style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "About",
            style: .plain,
            target: self,
            action: #selector(aboutTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Favorites",
            style: .plain,
            target: self,
            action: #selector(favoritesTapped)
        )
    }
    
    // MARK: - Navigation Actions
    @objc private func aboutTapped() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @objc private func favoritesTapped() {
        let favoritesVC = FavoritesViewController()
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    // MARK: - Data Loading
    private func loadCurrentYearMovies() {
        resetPagination()
        searchMode = false
        
        activityIndicator.startAnimating()
        
        networkService.getMoviesForYear(year: currentYear, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleMoviesResult(result, isLoadingMore: false)
            }
        }
    }
    
    private func searchMovies(query: String) {
        resetPagination()
        searchMode = true
        currentSearchQuery = query
        
        activityIndicator.startAnimating()
        
        networkService.searchMovies(query: query, page: currentPage, year: currentYear) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleMoviesResult(result, isLoadingMore: false)
            }
        }
    }
    
    private func loadMoreMovies() {
        guard !isLoadingMore && canLoadMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        showBottomLoader()
        
        let completion: (Result<MovieResponse, Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                self?.handleMoviesResult(result, isLoadingMore: true)
            }
        }
        
        if searchMode {
            networkService.searchMovies(query: currentSearchQuery, page: currentPage, year: currentYear, completion: completion)
        } else {
            networkService.getMoviesForYear(year: currentYear, page: currentPage, completion: completion)
        }
    }
    
    // MARK: - Helper Methods
    private func resetPagination() {
        currentPage = 1
        canLoadMore = true
        isLoadingMore = false
    }
    
    private func handleMoviesResult(_ result: Result<MovieResponse, Error>, isLoadingMore: Bool) {
        activityIndicator.stopAnimating()
        
        if isLoadingMore {
            self.isLoadingMore = false
            hideBottomLoader()
        }
        
        switch result {
        case .success(let response):
            if isLoadingMore {
                if response.page >= response.totalPages {
                    canLoadMore = false
                } else {
                    movies.append(contentsOf: response.results)
                    tableView.reloadData()
                }
            } else {
                movies = response.results
                tableView.reloadData()
                canLoadMore = response.page < response.totalPages
            }
            
        case .failure(let error):
            if isLoadingMore {
                currentPage -= 1 // Rollback
            }
            showError(error)
        }
    }
    
    private func showBottomLoader() {
        bottomLoadingIndicator.startAnimating()
        tableView.tableFooterView = bottomLoadingIndicator
    }
    
    private func hideBottomLoader() {
        bottomLoadingIndicator.stopAnimating()
        tableView.tableFooterView = nil
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

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMovie = movies[indexPath.row]
        let detailVC = DetailViewController(movie: selectedMovie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = scrollView.frame.height * 0.8 // Адаптивный threshold
        let contentHeight = scrollView.contentSize.height
        let scrollPosition = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if scrollPosition > contentHeight - threshold && canLoadMore && !isLoadingMore {
            loadMoreMovies()
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces), !query.isEmpty else {
            return
        }
        searchMovies(query: query)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadCurrentYearMovies()
        }
    }
}
