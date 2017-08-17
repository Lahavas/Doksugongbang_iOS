//
//  BookDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class BookDetailViewController: UIViewController {

    // MARK: - Properties
    
    let store: BookStore = BookStore.shared
    
    let realm = try! Realm()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()
    
    var book: Book!
    
    @IBOutlet var coverImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var pubdateLabel: UILabel!
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let bookIsbn = self.book.isbn,
            let book = realm.object(ofType: Book.self, forPrimaryKey: bookIsbn) {
            self.book = book
        }
        
        if let book = self.book {
            
            self.titleLabel.text = book.title
            self.subtitleLabel.text = book.subtitle
            self.authorLabel.text = book.author
            self.publisherLabel.text = book.publisher
            self.pubdateLabel.text = dateFormatter.string(from: book.pubdate)
            self.pageLabel.text = String(book.page)
            self.categoryLabel.text = book.category
            self.descriptionLabel.text = book.bookDescription
            
            self.store.fetchImage(for: book) {
                (result) -> Void in
                
                switch result {
                case let .success(image):
                    self.coverImageView.image = image
                case let .failure(error):
                    print("Error fetching image for photo: \(error)")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func addAction(_ sender: UIButton) {
        
        if !(self.book.bookStateEnum == .reading) {
            
            try! realm.write {
                self.book.bookStateEnum = .reading
                realm.add(self.book, update: true)
            }
            
            navigationController!.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        
        if self.book.isFavorite == false {
            
            try! realm.write {
                self.book.isFavorite = true
                realm.add(self.book, update: true)
            }
            
            navigationController!.popToRootViewController(animated: true)
        }
    }
}
