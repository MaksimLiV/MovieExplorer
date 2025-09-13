//
//  UIImageView.swift
//  MovieExplorer
//
//  Created by Maksim Li on 09/09/2025.
//

import UIKit

extension UIImageView {
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return
        }
        
        ImageLoader.shared.loadImage(from: url) { [weak self] image in
            self?.image = image ?? placeholder
        }
    }
}
