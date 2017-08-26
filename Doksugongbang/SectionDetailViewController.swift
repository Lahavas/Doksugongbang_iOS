//
//  SectionDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 17..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class SectionDetailViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var sectionBookListTableView: UITableView!
    
    // MARK: Model
    
    let store = BookStore.shared
    
    var book: Book!
    var bookList: [Book]!
    
    // MARK: Extra
    
    let realm = try! Realm()
    
    var selectedSection: String! {
        didSet {
            guard let sectionString = self.selectedSection else {
                preconditionFailure("Unexpected String")
            }
            
            self.title = sectionString
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sectionBookListTableView.delegate = self
        self.sectionBookListTableView.dataSource = self
        
        self.sectionBookListTableView.rowHeight = UITableViewAutomaticDimension
        self.sectionBookListTableView.estimatedRowHeight = 160
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpSelectedSectionBookList()
    }

    // MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: self)
        
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
        
        self.sectionBookListTableView.reloadData()
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
    
    // MARK: - Methods
    
    func setUpSelectedSectionBookList() {
        
        guard let sectionString = self.selectedSection else {
            preconditionFailure("Unexpected String")
        }
        
        switch sectionString {
        case "읽고 싶은 책":
            self.bookList = self.realm
                .objects(Book.self)
                .filter("isFavorite = True")
                .sorted(byKeyPath: "dateUpdatedFavorite", ascending: false)
                .toArray()
        case "베스트 셀러":
            var bestSellerListURL: URL {
                
                return AladinAPI.aladinApiURL(method: .itemList,
                                              parameters: ["SearchTarget": "Book",
                                                           "QueryType": "BestSeller"])
            }
            
            self.store.fetchBookList(url: bestSellerListURL) {
                (bookListResult) -> Void in
                
                switch bookListResult {
                case let .success(bookList):
                    self.bookList = bookList
                    DispatchQueue.main.async {
                        self.sectionBookListTableView.reloadData()
                    }
                case let .failure(error):
                    print(error)
                }
            }
        case "새로 나온 책":
            var itemNewSpecialListURL: URL {
                
                return AladinAPI.aladinApiURL(method: .itemList,
                                              parameters: ["SearchTarget": "Book",
                                                           "QueryType": "ItemNewSpecial"])
            }
            
            self.store.fetchBookList(url: itemNewSpecialListURL) {
                (bookListResult) -> Void in
                
                switch bookListResult {
                case let .success(bookList):
                    self.bookList = bookList
                    DispatchQueue.main.async {
                        self.sectionBookListTableView.reloadData()
                    }
                case let .failure(error):
                    print(error)
                }
            }
        default:
            self.bookList = realm
                .objects(Book.self)
                .filter("bookState = '\(sectionString)'")
                .sorted(byKeyPath: "dateUpdatedBookState", ascending: false)
                .toArray()
        }
        
        self.sectionBookListTableView.reloadData()
    }
}

// MARK: -

extension SectionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
