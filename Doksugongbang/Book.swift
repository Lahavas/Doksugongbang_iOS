//
//  Book.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import Foundation
import RealmSwift

enum BookState: String {
    case none
    case reading
    case read
    
    static let allValues = [none,
                            reading,
                            read]
}

class Book: Object {
    
    // MARK: - Properties
    
    // 책 고유번호
    dynamic var isbn: String? = ""
    
    // 책 정보
    dynamic var title: String = ""
    dynamic var author: String = ""
    dynamic var publisher: String = ""
    dynamic var pubdate: Date = Date()
    
    // 책 세부정보
    dynamic var page: Int = 0
    dynamic var category: String = ""
    dynamic var bookDescription: String? = ""
    
    // 책 링크
    dynamic var bookCoverUrl: String? = ""
    dynamic var bookLinkUrl: String? = ""
    
    // 책 상태
    dynamic var bookReadCount: Int = 0
    dynamic var isFavorite: Bool = false
    dynamic var bookState = BookState.none.rawValue
    var bookStateEnum: BookState {
        get {
            return BookState(rawValue: bookState)!
        }
        set {
            bookState = newValue.rawValue
        }
    }
    
    // 책 시간
    dynamic var dateUpdatedFavorite: Date = Date()
    dynamic var dateUpdatedBookState: Date = Date()
    
    // MARK: - Methods
    
    override static func primaryKey() -> String? {
        return "isbn"
    }
    
    static func isExist(book: Book) -> Book? {
        
        let realm = try! Realm()
        
        if let bookIsbn = book.isbn,
            let existingBook = realm.object(ofType: Book.self, forPrimaryKey: bookIsbn) {
            return existingBook
        } else {
            return nil
        }
    }
}
