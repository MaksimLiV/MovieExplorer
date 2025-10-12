//
//  FavoritesViewController.swift
//  MovieExplorer
//
//  Created by Maksim Li on 11/09/2025.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.rowHeight = 110
        return table
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your favorite movies will appear here"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Data
    private var favoriteMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriteMovies()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Placeholder constraints
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Management
    private func loadFavoriteMovies() {
        favoriteMovies = UserDefaults.standard.getFavoriteMovies()
        updateUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if self.favoriteMovies.isEmpty {
                self.tableView.isHidden = true
                self.placeholderLabel.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.placeholderLabel.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableView DataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = favoriteMovies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - TableView Delegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMovie = favoriteMovies[indexPath.row]
        let detailVC = DetailViewController(movie: selectedMovie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Swipe to delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieToRemove = favoriteMovies[indexPath.row]
            
            UserDefaults.standard.removeFromFavorites(movieToRemove)
            
            favoriteMovies.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if favoriteMovies.isEmpty {
                updateUI()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
}
