//
//  BookInfo.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import Foundation
import RealmSwift

class BookInfo: Object {
    
    // MARK: - Properties
    
    dynamic var bookInfoId: String = UUID().uuidString
    
    dynamic var bookReadCount: Int = 0
    dynamic var bookRating: Int = 0
    
    dynamic var reportBeforeReading: String = ""
    dynamic var reportAfterReading: String = ""
    
    dynamic var bookTotalPage: Int = 0
    dynamic var bookReadingPage: Int = 0
    
    dynamic var dateUpdated: Date = Date()
    
    let books = LinkingObjects(fromType: Book.self, property: "bookInfos")
    
    // MARK: - Methods
    
    override static func primaryKey() -> String? {
        return "bookInfoId"
    }
}
