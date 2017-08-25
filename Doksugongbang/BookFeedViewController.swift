//
//  BookFeedViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 26..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import CloudKit
import MobileCoreServices

class BookFeedViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var bookFeedTableView: UITableView!
    
    // MARK: Models
    
    var bookFeed: BookFeed!
    var bookFeedList: [BookFeed] = []
    
    // MARK: CloudKit
    
    let container = CKContainer.default()
    var publicDatabase: CKDatabase!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.publicDatabase = container.publicCloudDatabase
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.queryBookFeed()
    }

    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func queryBookFeed() {
        
        let predicate: NSPredicate = NSPredicate(value: true)
        
        let query: CKQuery = CKQuery(recordType: CloudKitConfig.recordType, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {
            (results, error) -> Void in
            
            if let results = results {
                
                for result in results {
                    
                    let userName: String = result.object(forKey: "userName") as! String
                    let bookTitle: String = result.object(forKey: "bookTitle") as! String
                    let bookIsbn: String = result.object(forKey: "bookIsbn") as! String
                    let bookRating: Int = result.object(forKey: "bookRating") as! Int
                    let bookReport: String = result.object(forKey: "bookReport") as! String
                    
                    guard let dateUpdated: Date = result.creationDate else {
                        preconditionFailure("Unexpected date")
                    }
                    
                    let bookFeed: BookFeed = BookFeed(userName: userName,
                                                      bookTitle: bookTitle,
                                                      bookIsbn: bookIsbn,
                                                      bookRating: bookRating,
                                                      bookReport: bookReport,
                                                      dateUpdated: dateUpdated)
                    
                    self.bookFeedList.append(bookFeed)
                }
            } else {
                
                preconditionFailure("Unexpected results")
            }
        }
    }
}
