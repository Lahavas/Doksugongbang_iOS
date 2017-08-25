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
    
    var book: Book = Book()
    
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
        self.bookFeedTableView.estimatedRowHeight = 400.0
        
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ReportBeforeRead":
            guard let reportBeforeReadViewController = segue.destination as? ReportBeforeReadViewController else {
                preconditionFailure("Unexpected Segue Destination")
            }
            
            reportBeforeReadViewController.book = self.book
        case "ReportAfterRead":
            guard let reportAfterReadViewController = segue.destination as? ReportAfterReadViewController else {
                preconditionFailure("Unexpected Segue Destination")
            }
            
            reportAfterReadViewController.book = self.book
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
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
                    
                    var bookLookUpURL: URL {
                        
                        return AladinAPI.aladinApiURL(method: .itemLookUp,
                                                      parameters: ["itemIdType": "ISBN13",
                                                                   "itemId": bookIsbn])
                    }
                    
                    self.store.fetchBook(url: bookLookUpURL) {
                        (bookResult) -> Void in
                        
                        switch bookResult {
                        case let .success(book):
                            
                            if let existingBook = Book.isExist(book: book) {
                                self.book = existingBook
                            }
                            
                            let bookFeed: BookFeed = BookFeed(userName: userName,
                                                              book: self.book,
                                                              bookRating: bookRating,
                                                              bookReport: bookReport,
                                                              dateUpdated: dateUpdated)
                            
                            self.bookFeedList.append(bookFeed)
                            self.bookFeedTableView.reloadData()
                        case let .failure(error):
                            print(error)
                        }
                    }
                }
            } else {
                
                preconditionFailure("Unexpected results")
            }
        }
    }
    
    // MARK: - Actions
    
    func likeButtonAction(_ sender: UIButton) {
        
        let button: UIButton = sender
        
        guard
            let stackView = button.superview,
            let contentView = stackView.superview,
            let cell = contentView.superview as? BookFeedListTableViewCell else {
                preconditionFailure("Unexpected sender")
        }
        
        let selectedBook: Book = cell.book
        
        if selectedBook.isFavorite == false {
            
            try! realm.write {
                selectedBook.isFavorite = true
                selectedBook.dateUpdatedFavorite = Date()
                realm.add(selectedBook, update: true)
                button.isSelected = true
            }
        } else {
            
            try! realm.write {
                selectedBook.isFavorite = false
                selectedBook.dateUpdatedFavorite = Date()
                realm.add(selectedBook, update: true)
                button.isSelected = false
            }
        }
        
        self.bookFeedTableView.reloadData()
    }
    
    func bookButtonAction(_ sender: UIButton) {
        
        let button: UIButton = sender
        
        guard
            let stackView = button.superview,
            let contentView = stackView.superview,
            let cell = contentView.superview as? BookListTableViewCell else {
                preconditionFailure("Unexpected sender")
        }
        
        self.book = cell.book
        
        if self.book.bookStateEnum == .reading {
            performSegue(withIdentifier: "ReportAfterRead", sender: self)
        } else {
            performSegue(withIdentifier: "ReportBeforeRead", sender: self)
        }
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
        
        cell.book = bookFeed.book
        
        cell.likeButton.addTarget(self,
                                  action: #selector(self.likeButtonAction(_:)),
                                  for: .touchUpInside)
        
        cell.bookButton.addTarget(self,
                                  action: #selector(self.bookButtonAction(_:)),
                                  for: .touchUpInside)
        
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        cell.publisherLabel.text = "\(book.publisher) 펴냄"
        cell.pubdateLabel.text = "\(CustomDateFormatter.longType.string(from: book.pubdate)) 출판"
        self.store.fetchImage(for: book) {
            (result) -> Void in
            
            switch result {
            case let .success(image):
                cell.update(with: image)
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
        
        if book.isFavorite == false {
            cell.likeButton.isSelected = false
        } else {
            cell.likeButton.isSelected = true
        }
        
        if book.bookStateEnum == .reading {
            cell.bookButton.isSelected = true
        } else {
            cell.bookButton.isSelected = false
        }
        
        return cell
    }
}
