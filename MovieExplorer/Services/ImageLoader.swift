//
//  ImageLoader.swift
//  MovieExplorer
//
//  Created by Maksim Li on 09/09/2025.
//

import UIKit
import Foundation

class ImageLoader {
    static let shared = ImageLoader()
    private init() {}
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: URL, completion: @escaping(UIImage?) -> Void) {
        let cacheKey = NSString(string: url.absoluteString)
        
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        downloadImage(from: url, cacheKey: cacheKey, completion: completion)
    }
    
    private func downloadImage(from url: URL, cacheKey: NSString, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self?.imageCache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
