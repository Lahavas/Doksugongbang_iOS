//
//  BookFeedViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 26..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit
import MobileCoreServices

class BookFeedViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var bookFeedTableView: UITableView!
    
    // MARK: Models
    
    var bookFeedList: [BookFeed] = []
    
    let store: BookStore = BookStore.shared
    
    // MARK: CloudKit
    
    let container = CKContainer.default()
    var publicDatabase: CKDatabase!
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "북 피드"
        
        self.bookFeedTableView.delegate = self
        self.bookFeedTableView.dataSource = self
        
        self.bookFeedTableView.rowHeight = UITableViewAutomaticDimension
        self.bookFeedTableView.estimatedRowHeight = 200.0
        
        self.publicDatabase = container.publicCloudDatabase
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpBookFeedList()
    }

    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func setUpBookFeedList() {
        
        let query: CKQuery = {
            let predicate: NSPredicate = NSPredicate(value: true)
            let query: CKQuery = CKQuery(recordType: CloudKitConfig.recordType, predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
            return query
        }()
        
        publicDatabase.perform(query, inZoneWith: nil) {
            (results, error) -> Void in
            
            if let results = results {
                
                self.bookFeedList.removeAll(keepingCapacity: true)
                
                for result in results {
                    
                    self.queryBookFeed(result: result)
                }
                
                self.bookFeedTableView.reloadData()
            } else {
                
                preconditionFailure("Unexpected results")
            }
        }
    }
    
    func queryBookFeed(result: CKRecord) {
        
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
}

// MARK: -

extension BookFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookFeedList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "BookFeedListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BookFeedListTableViewCell else {
            preconditionFailure("The dequeue cell is not instance of BookFeedListTableViewCell")
        }
        
        let bookFeed: BookFeed = self.bookFeedList[indexPath.row]
        
        cell.userNameLabel.text = "\(bookFeed.userName) 님이 이 책을 읽었습니다!"
        cell.dateUpdatedLabel.text = CustomDateFormatter.longType.string(from: bookFeed.dateUpdated)
        
        cell.bookReportLabel.text = bookFeed.bookReport
        cell.bookRating.rating = bookFeed.bookRating
        cell.titleLabel.text = bookFeed.bookTitle
        
        return cell
    }
}
