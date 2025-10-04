//
//  DetailViewController.swift
//  MovieExplorer
//
//  Created by Maksim Li on 11/09/2025.
//

import UIKit

class DetailViewController: UIViewController {
    
    private let movie: Movie
    private var isFavorite: Bool = false
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Header section with background color
    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemOrange
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    // Info section with white background
    private let infoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Release date"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "User rating"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let adultTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Adult"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let adultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let separatorLine1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private let separatorLine2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private let separatorLine3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4
        return view
    }()
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        configureWithMovieData()
        checkFavoriteStatus()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Details"
        
        // Add main containers
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add sections
        contentView.addSubview(headerContainerView)
        contentView.addSubview(infoContainerView)
        
        // Add elements to header
        headerContainerView.addSubview(posterImageView)
        headerContainerView.addSubview(titleLabel)
        
        // Add elements to info section
        infoContainerView.addSubview(descriptionTitleLabel)
        infoContainerView.addSubview(descriptionLabel)
        
        infoContainerView.addSubview(releaseDateTitleLabel)
        infoContainerView.addSubview(releaseDateLabel)
        
        infoContainerView.addSubview(ratingTitleLabel)
        infoContainerView.addSubview(ratingLabel)
        
        infoContainerView.addSubview(adultTitleLabel)
        infoContainerView.addSubview(adultLabel)
        
        infoContainerView.addSubview(separatorLine1)
        infoContainerView.addSubview(separatorLine2)
        infoContainerView.addSubview(separatorLine3)
        
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    @objc private func favoriteButtonTapped() {
        UserDefaults.standard.toggleFavorite(movie)
        checkFavoriteStatus()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header container constraints
            headerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Poster constraints
            posterImageView.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 0),
            posterImageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 5),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            
            // Bottom of header container
            headerContainerView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 0),
            
            // Info container constraints
            infoContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            infoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Description section
            descriptionTitleLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 12),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 1),
            descriptionLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            separatorLine1.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            separatorLine1.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            separatorLine1.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            separatorLine1.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Release date section
            releaseDateTitleLabel.topAnchor.constraint(equalTo: separatorLine1.bottomAnchor, constant: 5),
            releaseDateTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            releaseDateTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            releaseDateLabel.topAnchor.constraint(equalTo: releaseDateTitleLabel.bottomAnchor, constant: 1),
            releaseDateLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            separatorLine2.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 5),
            separatorLine2.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            separatorLine2.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            separatorLine2.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Rating section
            ratingTitleLabel.topAnchor.constraint(equalTo: separatorLine2.bottomAnchor, constant: 5),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            ratingTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            ratingLabel.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 1),
            ratingLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            ratingLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            separatorLine3.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 5),
            separatorLine3.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            separatorLine3.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            separatorLine3.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Adult section
            adultTitleLabel.topAnchor.constraint(equalTo: separatorLine3.bottomAnchor, constant: 5),
            adultTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            adultTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            
            adultLabel.topAnchor.constraint(equalTo: adultTitleLabel.bottomAnchor, constant: 1),
            adultLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            adultLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            adultLabel.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureWithMovieData() {
        titleLabel.text = movie.title
        descriptionLabel.text = movie.overview.isEmpty ? "No description available" : movie.overview
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: movie.releaseDate) {
            dateFormatter.dateFormat = "dd.MM.yyyy"
            releaseDateLabel.text = dateFormatter.string(from: date)
        } else {
            releaseDateLabel.text = movie.releaseDate.isEmpty ? "Unknown" : movie.releaseDate
        }
        
        // Format rating
        ratingLabel.text = String(format: "%.1f out of 10.0", movie.voteAverage)
        adultLabel.text = movie.adult ? "Yes" : "No"
        
        // Load poster image
        if let posterURL = movie.fullPosterURL {
            posterImageView.loadImage(from: posterURL, placeholder: UIImage(systemName: "photo"))
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Favorites Management
    private func checkFavoriteStatus() {
        isFavorite = UserDefaults.standard.isFavorite(movie)
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let imageName = isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
    }
}
