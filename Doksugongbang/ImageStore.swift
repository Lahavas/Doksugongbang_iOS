//
//  ImageStore.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

class ImageStore {
    
    // MARK: - Properties
    
    static let shared = ImageStore()
    
    let cache = NSCache<NSString, UIImage>()
    
    // MARK: - ImageStore Management
    
    func setImage(_ image: UIImage, forKey key: String) {
        
        cache.setObject(image, forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            let _ = try? data.write(to: url, options: [.atomic])
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }
        
        let url = imageURL(forKey: key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key as NSString)
        
        return imageFromDisk
    }
    
    func deleteImage(forKey key: String) {
        
        cache.removeObject(forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
    }
    
    private func imageURL(forKey key: String) -> URL {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            preconditionFailure("Cannot find document directory")
        }
        
        return documentDirectory.appendingPathComponent(key)
    }
}
