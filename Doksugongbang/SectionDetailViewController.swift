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
    
    @IBOutlet var bookCollectionView: UICollectionView!
    
    let realm = try! Realm()
    
    let store = BookStore.shared
    
    var selectedSection: String?
    
    var book: Book!
    var bookList: [Book]!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let sectionString = selectedSection else {
            preconditionFailure("Unexpected String")
        }
        
        if sectionString == "favorite" {
            bookList = realm
                .objects(Book.self)
                .filter("isFavorite = True")
                .sorted(byKeyPath: "dateUpdatedFavorite", ascending: false)
                .toArray()
        } else {
            bookList = realm
                .objects(Book.self)
                .filter("bookState = '\(sectionString)'")
                .sorted(byKeyPath: "dateUpdatedBookState", ascending: false)
                .toArray()
        }
        
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

extension SectionDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let book = self.bookList[indexPath.row]
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.book = self.bookList[indexPath.row]
        
        self.performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    // MARK: - Collection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "BookCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? BookCollectionViewCell else {
            preconditionFailure("The dequeued cell is not an instance of BookCollectionViewCell.")
        }
        
        return cell
    }
}
