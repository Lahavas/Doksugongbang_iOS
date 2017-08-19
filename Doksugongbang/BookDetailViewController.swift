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
    
    // MARK: Outlets
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var pubdateLabel: UILabel!
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var starButton: UIButton!
    
    // MARK: Model
    
    var book: Book!
    
    let store: BookStore = BookStore.shared
    
    // MARK: Extra
    
    let realm = try! Realm()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let existingBook = Book.isExist(book: self.book) {
            self.book = existingBook
        }
        
        self.setUpImageButton()
        self.setUpBookDetailView()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        
        if self.book.isFavorite == false {
            
            try! realm.write {
                self.book.isFavorite = true
                realm.add(self.book, update: true)
                self.likeButton.isSelected = true
            }
        } else {
            
            try! realm.write {
                self.book.isFavorite = false
                realm.add(self.book, update: true)
                self.likeButton.isSelected = false
            }
        }
    }
    
    @IBAction func starButtonAction(_ sender: UIButton) {
        
        if !(self.book.bookStateEnum == .reading) {
            
            try! realm.write {
                self.book.bookStateEnum = .reading
                realm.add(self.book, update: true)
            }
            
            navigationController!.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Methods
    
    func setUpBookDetailView() {
        
        if let book = self.book {
            
            self.titleLabel.text = book.title
            self.authorLabel.text = book.author
            self.publisherLabel.text = book.publisher
            self.pubdateLabel.text = dateFormatter.string(from: book.pubdate)
            self.pageLabel.text = "\(String(book.page))p"
            self.categoryLabel.text = book.category
            self.descriptionLabel.text = book.bookDescription
            
            self.store.fetchImage(for: book) {
                (result) -> Void in
                
                switch result {
                case let .success(image):
                    self.update(with: image)
                case let .failure(error):
                    print("Error fetching image for photo: \(error)")
                }
            }
        }
    }
    
    func setUpImageButton() {
        
        let bundle = Bundle(for: type(of: self))
        
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let selectedStar = UIImage(named: "selectedStar", in: bundle, compatibleWith: self.traitCollection)
        
        let emptyLike = UIImage(named: "emptyLike", in: bundle, compatibleWith: self.traitCollection)
        let selectedLike = UIImage(named: "selectedLike", in: bundle, compatibleWith: self.traitCollection)
        
        self.starButton.setImage(emptyStar, for: .normal)
        self.starButton.setImage(selectedStar, for: .selected)
        
        self.likeButton.setImage(emptyLike, for: .normal)
        self.likeButton.setImage(selectedLike, for: .selected)
        
        self.starButton.translatesAutoresizingMaskIntoConstraints = false
        self.starButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        self.starButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true

        self.likeButton.translatesAutoresizingMaskIntoConstraints = false
        self.likeButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        self.likeButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        if self.book.isFavorite == false {
            self.likeButton.isSelected = false
        } else {
            self.likeButton.isSelected = true
        }
        
        if self.book.bookStateEnum == .none {
            self.starButton.isSelected = false
        } else {
            self.starButton.isSelected = true
        }
    }
    
    func update(with image: UIImage?) {
        
        if let imageToDisplay = image {
            self.spinner.stopAnimating()
            self.coverImageView.image = imageToDisplay
        } else {
            self.spinner.startAnimating()
            self.coverImageView.image = nil
        }
    }
}
