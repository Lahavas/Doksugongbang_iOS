//
//  SearchBookListViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class SearchBookListViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var searchBookListTableView: UITableView!
    
    // MARK: Model
    
    let store: BookStore = BookStore.shared
    
    var book: Book!
    var bookList: [Book]!
    
    // MARK: Extra
    
    let realm = try! Realm()
    
    var searchText: String! {
        didSet {
            guard let searchText = self.searchText else {
                preconditionFailure("Unexpected search text")
            }
            
            self.title = "검색어: \(searchText)"
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBookListTableView.delegate = self
        self.searchBookListTableView.dataSource = self
        
        self.searchBookListTableView.rowHeight = UITableViewAutomaticDimension
        self.searchBookListTableView.estimatedRowHeight = 160
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchBookListTableView.reloadData()
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
        case "ShowDetail":
            guard let bookDetailViewController = segue.destination as? BookDetailViewController else {
                preconditionFailure("Unexpected destination: \(segue.destination)")
            }
            
            bookDetailViewController.book = self.book
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }
    
    // MARK: - Actions
    
    func likeButtonAction(_ sender: UIButton) {
        
        let button: UIButton = sender
        
        guard
            let stackView = button.superview,
            let contentView = stackView.superview,
            let cell = contentView.superview as? BookListTableViewCell else {
                preconditionFailure("Unexpected sender")
        }
        
        if let existingBook = Book.isExist(book: cell.book) {
            
            if existingBook.isFavorite == false {
                
                try! self.realm.write {
                    existingBook.isFavorite = true
                    existingBook.dateUpdatedFavorite = Date()
                    self.realm.add(existingBook, update: true)
                    button.isSelected = true
                }
            } else {
                
                try! self.realm.write {
                    existingBook.isFavorite = false
                    existingBook.dateUpdatedFavorite = Date()
                    self.realm.add(existingBook, update: true)
                    button.isSelected = false
                }
            }
            
            guard let indexPath = self.searchBookListTableView.indexPath(for: cell) else {
                preconditionFailure("Unexpected cell")
            }
            
            self.searchBookListTableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            
            if let isbnString = cell.book.isbn {
                var bookLookUpURL: URL {
                    
                    return AladinAPI.aladinApiURL(method: .itemLookUp,
                                                  parameters: ["itemIdType": "ISBN13",
                                                               "itemId": isbnString])
                }
                
                self.store.fetchBook(url: bookLookUpURL) {
                    (bookResult) -> Void in
                    
                    switch bookResult {
                    case let .success(book):
                        
                        try! self.realm.write {
                            book.isFavorite = true
                            book.dateUpdatedFavorite = Date()
                            self.realm.add(book, update: true)
                            button.isSelected = true
                        }
                        
                        guard let indexPath = self.searchBookListTableView.indexPath(for: cell) else {
                            preconditionFailure("Unexpected cell")
                        }
                        
                        self.searchBookListTableView.reloadRows(at: [indexPath], with: .automatic)
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func bookButtonAction(_ sender: UIButton) {
        
        let button: UIButton = sender
        
        guard
            let stackView = button.superview,
            let contentView = stackView.superview,
            let cell = contentView.superview as? BookListTableViewCell else {
                preconditionFailure("Unexpected sender")
        }
        
        if let existingBook = Book.isExist(book: cell.book) {
            
            self.book = cell.book
            
            if cell.book.bookStateEnum == .reading {
                self.performSegue(withIdentifier: "ReportAfterRead", sender: self)
            } else {
                self.performSegue(withIdentifier: "ReportBeforeRead", sender: self)
            }
        } else {
            
            if let isbnString = cell.book.isbn {
                
                var bookLookUpURL: URL {
                    
                    return AladinAPI.aladinApiURL(method: .itemLookUp,
                                                  parameters: ["itemIdType": "ISBN13",
                                                               "itemId": isbnString])
                }
                
                self.store.fetchBook(url: bookLookUpURL) {
                    (bookResult) -> Void in
                    
                    switch bookResult {
                    case let .success(book):
                        
                        self.book = book
                        
                        if book.bookStateEnum == .reading {
                            self.performSegue(withIdentifier: "ReportAfterRead", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "ReportBeforeRead", sender: self)
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
}

// MARK: -

extension SearchBookListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let bookList = self.bookList {
            return bookList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "BookListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BookListTableViewCell else {
            preconditionFailure("The dequeued cell is not an instance of BookListTableViewCell.")
        }
        
        var book = self.bookList[indexPath.row]
        
        if let existingBook = Book.isExist(book: book) {
            book = existingBook
        }
        
        cell.book = book
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedBook = self.bookList[indexPath.row]
        
        if let isbnString = selectedBook.isbn {
            var bookLookUpURL: URL {
                
                return AladinAPI.aladinApiURL(method: .itemLookUp,
                                              parameters: ["itemIdType": "ISBN13",
                                                           "itemId": isbnString])
            }
            
            self.store.fetchBook(url: bookLookUpURL) {
                (bookResult) -> Void in
                
                switch bookResult {
                case let .success(book):
                    self.book = book
                    self.performSegue(withIdentifier: "ShowDetail", sender: self)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
