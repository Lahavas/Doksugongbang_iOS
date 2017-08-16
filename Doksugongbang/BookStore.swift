//
//  BookStore.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

enum BookResult {
    case success(Book)
    case failure(Error)
}

enum BookListResult {
    case success([Book])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum ImageError: Error {
    case imageCreationError
}

class BookStore {
    
    // MARK: - Properties
    
    let imageStore = ImageStore.shared
    
    static let shared = BookStore()
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    private let sessionQueue = DispatchQueue(label: URLSession.self.description(), attributes: [], target: nil)
    
    // MARK: - Fetching
    
    func fetchBook(url: URL, completion: @escaping (BookResult) -> Void) {
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processBookRequest(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    func fetchBookList(url: URL, completion: @escaping (BookListResult) -> Void) {
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processBookListRequest(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    func fetchImage(for book: Book, completion: @escaping (ImageResult) -> Void) {
        
        guard let bookKey = book.isbn else {
            preconditionFailure("Book expected to have a bookId.")
        }
        
        if let image = imageStore.image(forKey: bookKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard
            let bookCoverUrlString = book.bookCoverUrl,
            let bookCoverUrl = URL(string: bookCoverUrlString) else {
                preconditionFailure("Book expected to have a cover URL.")
        }
        
        let request = URLRequest(url: bookCoverUrl)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: bookKey)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    
    // MARK: - Request Process
    
    private func processBookRequest(data: Data?,
                                    error: Error?) -> BookResult {
        
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return AladinAPI.bookParsing(fromJSON: jsonData)
    }
    
    private func processBookListRequest(data: Data?,
                                        error: Error?) -> BookListResult {
        
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return AladinAPI.bookListParsing(fromJSON: jsonData)
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(ImageError.imageCreationError)
                }
        }
        
        return .success(image)
    }
}

