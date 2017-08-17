//
//  Results.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 17..
//  Copyright © 2017년 yeon. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    
    // MARK: - Realm's Results extension
    
    func toArray() -> [T] {
        var array = [T]()
        for result in self {
            array.append(result)
        }
        return array
    }
}
