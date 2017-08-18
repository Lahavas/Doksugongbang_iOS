//
//  SearchBookListViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

class SearchBookListViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var searchBookListTableView: UITableView!
    
    // MARK: Model
    
    let store: BookStore = BookStore.shared
    
    var book: Book!
    var bookList: [Book]!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.searchBookListTableView.delegate = self
        self.searchBookListTableView.dataSource = self
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
        case "ShowDetail":
            guard let bookDetailViewController = segue.destination as? BookDetailViewController else {
                preconditionFailure("Unexpected destination: \(segue.destination)")
            }
            
            bookDetailViewController.book = self.book
        default:
            preconditionFailure("Unexpected Segue Identifier")
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
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 120
            
            return bookList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "SearchBookListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SearchBookListTableViewCell else {
            preconditionFailure("The dequeued cell is not an instance of SearchBookListTableViewCell.")
        }
        
        let book = self.bookList[indexPath.row]
        
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        self.store.fetchImage(for: book) {
            (result) -> Void in
            
            switch result {
            case let .success(image):
                cell.coverImageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
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
