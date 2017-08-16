//
//  HomeViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    let realm = try! Realm()
    
    let store: BookStore = BookStore.shared
    
    var book: Book!
    var bookList: Results<Book>!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realm Browser file 위치
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        bookList = realm.objects(Book.self)
        
        for book in bookList {
            print(book.title)
            print(book.bookState)
        }
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
