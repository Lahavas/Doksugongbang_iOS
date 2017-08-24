//
//  BookLog.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import Foundation
import RealmSwift

class BookLog: Object {
    
    // MARK: - Properties
    
    dynamic var bookLogId: String = UUID().uuidString
    
    dynamic var startPage: Int = 0
    dynamic var endPage: Int = 0
    
    dynamic var logContent: String = ""
    
    dynamic var dateUpdated: Date = Date()
    dynamic var dateString: String = ""
    
    dynamic var parentBookInfo: BookInfo?
    
    // MARK: - Methods
    
    override static func primaryKey() -> String? {
        return "bookLogId"
    }
}

