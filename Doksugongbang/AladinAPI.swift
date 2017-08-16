//
//  AladinAPI.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import Foundation

enum MethodForAladin: String {
    case itemList = "/ItemList.aspx"
    case itemLookUp = "/ItemLookUp.aspx"
    case itemSearch = "/ItemSearch.aspx"
}

enum AladinAPIError: Error {
    case invalidJSONData
}

struct AladinAPI {
    
    // MARK: - Configuration
    
    private static let baseURLString = AladinConfig.aladinBaseURLString
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: - API URL
    
    static func aladinApiURL(method: MethodForAladin,
                             parameters: [String: String]?) -> URL {
        
        let urlString = baseURLString + method.rawValue
        
        guard var components = URLComponents(string: urlString) else {
            preconditionFailure("Cannot find base url")
        }
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "ttbkey": AladinConfig.ttbKey,
            "output": "js",
            "Version": AladinConfig.aladinVersion
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("no url")
        }
        
        return url
    }
    
    // MARK: - JSON Parsing
    
    private static func bookLookUp(fromJSON json: [String: Any]) -> Book? {
        
        guard
            let bookInfoJson = json["subInfo"] as? [String: Any],
            let bookIsbn = json["isbn13"] as? String,
            let bookTitle = json["title"] as? String,
            let bookSubtitle = bookInfoJson["subTitle"] as? String,
            let bookAuthor = json["author"] as? String,
            let bookPublisher = json["publisher"] as? String,
            let bookPubdateString = json["pubDate"] as? String,
            let bookPage = bookInfoJson["itemPage"] as? Int,
            let bookCategory = json["categoryName"] as? String,
            let bookDescription = json["description"] as? String,
            let bookLinkUrl = json["link"] as? String,
            let bookCoverUrl = json["cover"] as? String,
            let bookPubdate = dateFormatter.date(from: bookPubdateString) else {
                return nil
        }
        
        var book: Book!
        
        book = Book()
        
        // 책 고유번호
        book.isbn = bookIsbn
        
        // 책 정보
        book.title = bookTitle
        book.subtitle = bookSubtitle
        book.author = bookAuthor
        book.publisher = bookPublisher
        book.pubdate = bookPubdate
        
        // 책 세부 정보
        book.page = bookPage
        book.category = bookCategory
        book.bookDescription = bookDescription
        
        // 책 링크
        book.bookLinkUrl = bookLinkUrl
        book.bookCoverUrl = bookCoverUrl
        
        return book
    }
    
    private static func bookListSearch(fromJSON json: [String: Any]) -> Book? {
        
        guard
            let bookIsbn = json["isbn13"] as? String,
            let bookTitle = json["title"] as? String,
            let bookAuthor = json["author"] as? String,
            let bookPublisher = json["publisher"] as? String,
            let bookPubdateString = json["pubDate"] as? String,
            let bookCategory = json["categoryName"] as? String,
            let bookCoverUrl = json["cover"] as? String,
            let bookPubdate = dateFormatter.date(from: bookPubdateString) else {
                return nil
        }
        
        var book: Book!
        
        book = Book()
        
        // 책 고유번호
        book.isbn = bookIsbn
        
        // 책 정보
        book.title = bookTitle
        book.author = bookAuthor
        book.publisher = bookPublisher
        book.pubdate = bookPubdate
        
        // 책 세부 정보
        book.category = bookCategory
        
        // 책 링크
        book.bookCoverUrl = bookCoverUrl
        
        return book
    }
    
    static func bookParsing(fromJSON data: Data) -> BookResult {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let items = jsonDictionary["item"] as? [[String: Any]] else {
                    return .failure(AladinAPIError.invalidJSONData)
            }
            
            guard let book = self.bookLookUp(fromJSON: items[0]) else {
                return .failure(AladinAPIError.invalidJSONData)
            }
            
            return .success(book)
        } catch let error {
            return .failure(error)
        }
    }
    
    static func bookListParsing(fromJSON data: Data) -> BookListResult {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let items = jsonDictionary["item"] as? [[String: Any]] else {
                    return .failure(AladinAPIError.invalidJSONData)
            }
            
            var bookList: [Book] = [Book]()
            for item in items {
                if let book = self.bookListSearch(fromJSON: item) {
                    bookList.append(book)
                }
            }
            
            if bookList.isEmpty && !items.isEmpty {
                return .failure(AladinAPIError.invalidJSONData)
            }
            
            return .success(bookList)
        } catch let error {
            return .failure(error)
        }
    }
}
