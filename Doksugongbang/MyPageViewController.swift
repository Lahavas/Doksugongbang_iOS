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
    
    var bookList: Results<Book>!
    
    var numberOfSection: Int = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bookCollectionView.delegate = self
        self.bookCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bookList = realm.objects(Book.self)
        bookCollectionView.reloadData()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    
//    private func setUpCollectionViewInfo() {
//        
//        
//        
//        favoriteBookList = realm.objects(Book.self).filter("isFavorite = True").sorted(byKeyPath: "dateUpdatedFavorite")
//        
//        readingBookList = realm
//            .objects(Book.self)
//            .filter("bookState = 'reading'")
//            .sorted(byKeyPath: "dateUpdatedBookState")
//        
//        readBookList = realm
//            .objects(Book.self)
//            .filter("bookState = 'read'")
//            .sorted(byKeyPath: "dateUpdatedBookState")
//        
//        unreadBookList = realm
//            .objects(Book.self)
//            .filter("bookState = 'unread'")
//            .sorted(byKeyPath: "dateUpdatedBookState")
//    }
}

// MARK: -

extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let book = bookList[indexPath.row]
        
        store.fetchImage(for: book) {
            (result) -> Void in
            
            guard let bookIndex = self.bookList.index(of: book),
                case let .success(image) = result else {
                    return
            }
            let bookIndexPath = IndexPath(item: bookIndex, section: 0)
            
            if let cell = self.bookCollectionView.cellForItem(at: bookIndexPath) as? BookCollectionViewCell {
                cell.titleLabel.text = book.title
                cell.update(with: image)
            }
        }
    }
    
    // MARK: - Collection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return BookState.allValues.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let bookList = self.bookList {
            print(bookList.count)
            return bookList.count
        } else {
            return 0
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
