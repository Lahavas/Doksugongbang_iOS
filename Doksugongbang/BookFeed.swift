//
//  BookFeed.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 24..
//  Copyright © 2017년 yeon. All rights reserved.
//

import Foundation

class BookFeed: NSObject {
    
    // MARK: - Properties
    
    var userName: String = ""
    
    var book: Book = Book()
    
    var bookReport: String = ""
    var bookRating: Int = 0
    
    var dateUpdated: Date = Date()
    
    // MARK: - Initialization
    
    init(userName: String, book: Book, bookRating: Int, bookReport: String, dateUpdated: Date) {
        
        self.userName = userName
        
        self.book = book
        self.bookReport = bookReport
        self.bookRating = bookRating
        
        self.dateUpdated = dateUpdated
    }
}
