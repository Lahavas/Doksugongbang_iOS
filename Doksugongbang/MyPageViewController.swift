//
//  MyPageViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class MyPageViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var bookCollectionView: UICollectionView!
    
    let realm = try! Realm()
    
    let store = BookStore.shared
    
    var bookList: [[Book]] = Array(repeating: Array(repeating: Book(), count:0), count: 4)
    var book: Book!
    
    var sections: [String] = [ "favorite", "reading", "read", "unread" ]
    var selectedSection: String?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bookCollectionView.delegate = self
        self.bookCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpBookList()
        bookCollectionView.reloadData()
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
        case "ShowSection":
            guard let sectionDetailViewController = segue.destination as? SectionDetailViewController else {
                preconditionFailure("Unexpected destination: \(segue.destination)")
            }
            
            sectionDetailViewController.selectedSection = self.selectedSection
        case "ShowDetail":
            guard let bookDetailViewController = segue.destination as? BookDetailViewController else {
                preconditionFailure("Unexpected destination: \(segue.destination)")
            }
            
            bookDetailViewController.book = self.book
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }
    
    // MARK: - Section Action
    
    func showBookListInSection(_ sender: UIButton) {
        
        self.selectedSection = self.sections[sender.tag]
        
        self.performSegue(withIdentifier: "ShowSection", sender: self)
    }
    
    // MARK: - Private Methods
    
    private func setUpBookList() {
        
        for section in 0..<sections.count {
            
            switch section {
            case 0:
                bookList[section] = realm
                    .objects(Book.self)
                    .filter("isFavorite = True")
                    .sorted(byKeyPath: "dateUpdatedFavorite", ascending: false)
                    .toArray()
            case 1:
                bookList[section] = realm
                    .objects(Book.self)
                    .filter("bookState = 'reading'")
                    .sorted(byKeyPath: "dateUpdatedBookState", ascending: false)
                    .toArray()
            case 2:
                bookList[section] = realm
                    .objects(Book.self)
                    .filter("bookState = 'read'")
                    .sorted(byKeyPath: "dateUpdatedBookState", ascending: false)
                    .toArray()
            case 3:
                bookList[section] = realm
                    .objects(Book.self)
                    .filter("bookState = 'unread'")
                    .sorted(byKeyPath: "dateUpdatedBookState", ascending: false)
                    .toArray()
            default:
                preconditionFailure("Index out of range")
            }
        }
    }
}

// MARK: -

extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let detailBookList = bookList[indexPath.section]
        let showingBook = detailBookList[indexPath.row]
        
        store.fetchImage(for: showingBook) {
            (result) -> Void in
            
            guard let bookIndex = detailBookList.index(of: showingBook),
                case let .success(image) = result else {
                    return
            }
            let bookIndexPath = IndexPath(item: bookIndex, section: indexPath.section)
            
            if let cell = self.bookCollectionView.cellForItem(at: bookIndexPath) as? BookCollectionViewCell {
                cell.titleLabel.text = showingBook.title
                cell.update(with: image)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let identifier = "BookCollectionReusableView"
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? BookCollectionReusableView else {
                preconditionFailure("The dequeued supplementary view is not an instance of BookCollectionReusableView.")
            }
    
            supplementaryView.sectionTitleLabel.text = sections[indexPath.section]
            
            if bookList[indexPath.section].count <= 3 {
                supplementaryView.showSectionButton.isHidden = true
            } else {
                supplementaryView.showSectionButton.isHidden = false
            }
            supplementaryView.showSectionButton.tag = indexPath.section
            supplementaryView.showSectionButton.addTarget(self,
                                                          action: #selector(self.showBookListInSection(_:)),
                                                          for: .touchUpInside)
            return supplementaryView
        default:
            preconditionFailure("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailBookList = bookList[indexPath.section]
        if let isbnString = detailBookList[indexPath.row].isbn {
            
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
    
    // MARK: - Collection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return bookList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let bookList = self.bookList[section]
        
        if bookList.count > 3 {
            return 3
        } else {
            return bookList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "BookCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? BookCollectionViewCell else {
            preconditionFailure("The dequeued cell is not an instance of BookCollectionViewCell.")
        }
        
        return cell
    }
}
