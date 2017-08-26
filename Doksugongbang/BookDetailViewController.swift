//
//  BookDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

///////////////////////////////////////////
//  수정 필요한 부분
//
//  1. 진행률 ProgressBar 수정
//
///////////////////////////////////////////

import UIKit
import RealmSwift
import SafariServices

class BookDetailViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    // Main View's Outlets
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var pubdateLabel: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var bookButton: UIButton!
    
    // Reading View's Outlets
    @IBOutlet var bookStateLabel: UILabel!
    @IBOutlet var bookCountLabel: UILabel!
    @IBOutlet var bookReadProgressView: UIProgressView!
    @IBOutlet var firstPageLabel: UILabel!
    @IBOutlet var lastPageLabel: UILabel!
    
    @IBOutlet var detailViewButton: UIButton!
    
    // Description View's Outlets
    @IBOutlet var pageLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    // Views
    @IBOutlet var mainView: UIView!
    @IBOutlet var readingView: UIView!
    @IBOutlet var descriptionView: UIView!
    
    // Constraints
    
    @IBOutlet var readingViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Model
    
    var book: Book!
    
    let store: BookStore = BookStore.shared
    
    // MARK: Extra
    
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "책 정보"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let existingBook = Book.isExist(book: self.book) {
            self.book = existingBook
        }
        
        if self.book.bookStateEnum == .reading {
            
            guard let addLogImage: UIImage = UIImage(named: "addLogIcon") else {
                preconditionFailure("Cannot find image")
            }
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addLogImage,
                                                                     style: .done,
                                                                     target: self,
                                                                     action: #selector(self.addBookLog(_:)))
        }
        
        self.setUpBookImage()
        
        self.setUpMainView()
        self.setUpReadingView()
        self.setUpBookDescriptionView()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigations
    
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
            guard let bookReportDetailViewController = segue.destination as? BookReportDetailViewController else {
                preconditionFailure("Unexpected Segue Destination")
            }
            
            bookReportDetailViewController.book = self.book
        case "AddBookLog":
            guard let bookLogDetailViewController = segue.destination as? BookLogDetailViewController else {
                preconditionFailure("Unexpected Segue Destination")
            }
            
            bookLogDetailViewController.book = self.book
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        
        if self.book.isFavorite == false {
            
            try! realm.write {
                self.book.isFavorite = true
                self.book.dateUpdatedFavorite = Date()
                realm.add(self.book, update: true)
                self.likeButton.isSelected = true
            }
        } else {
            
            try! realm.write {
                self.book.isFavorite = false
                self.book.dateUpdatedFavorite = Date()
                realm.add(self.book, update: true)
                self.likeButton.isSelected = false
            }
        }
    }
    
    @IBAction func bookButtonAction(_ sender: UIButton) {
        
        if self.book.bookStateEnum == .reading {
            performSegue(withIdentifier: "ReportAfterRead", sender: self)
        } else {
            performSegue(withIdentifier: "ReportBeforeRead", sender: self)
        }
    }
    
    @IBAction func openAmazonLink(_ sender: UIButton) {
        
        if let linkUrlString = self.book.bookLinkUrl,
            let linkUrl = URL(string: linkUrlString) {
            let safariViewController = SFSafariViewController(url: linkUrl)
            self.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func addBookLog(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "AddBookLog", sender: self)
    }
    
    // MARK: - Methods
    
    func setUpMainView() {
        
        if let book = self.book {
        
            self.titleLabel.text = book.title
            self.authorLabel.text = book.author
            self.publisherLabel.text = "\(book.publisher) 펴냄"
            self.pubdateLabel.text = "\(CustomDateFormatter.longType.string(from: book.pubdate)) 출판"
            
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
        
        if self.book.isFavorite == false {
            self.likeButton.isSelected = false
        } else {
            self.likeButton.isSelected = true
        }
        
        if self.book.bookStateEnum == .reading {
            self.bookButton.isSelected = true
        } else {
            self.bookButton.isSelected = false
        }
    }
    
    func setUpReadingView() {
        
        self.bookCountLabel.text = "\(self.book.bookReadCount)독차"
        
        switch self.book.bookStateEnum {
        case .reading:
            self.bookStateLabel.text = "읽고 있는 중입니다."
            self.detailViewButton.isHidden = false
            
            self.readingViewHeightConstraint.constant = 140.0
            
            if let bookInfo = self.book.bookInfos.filter("bookReadCount = \(self.book.bookReadCount)").first {
                
                let progressRating: Float = Float(bookInfo.bookReadingPage) / Float(bookInfo.bookTotalPage)
                self.bookReadProgressView.setProgress(progressRating, animated: true)
                
                self.firstPageLabel.text = "0쪽"
                self.lastPageLabel.text = "\(bookInfo.bookTotalPage)쪽"
            }
        case .read:
            self.bookStateLabel.text = "이미 읽은 책입니다."
            
            self.bookReadProgressView.isHidden = true
            self.firstPageLabel.isHidden = true
            self.lastPageLabel.isHidden = true
            self.detailViewButton.isHidden = false
            
            self.readingViewHeightConstraint.constant = 120.0
        case .none:
            self.bookStateLabel.text = "아직 읽은 적이 없습니다."
            
            self.bookReadProgressView.isHidden = true
            self.firstPageLabel.isHidden = true
            self.lastPageLabel.isHidden = true
            self.detailViewButton.isHidden = true
            
            self.readingViewHeightConstraint.constant = 100.0
        }
    }
    
    func setUpBookDescriptionView() {
        
        if let book = self.book {
            
            self.pageLabel.text = "\(book.page) 페이지"
            self.categoryLabel.text = book.category
            self.descriptionLabel.text = book.bookDescription
        }
    }
    
    func setUpBookImage() {
        
        self.coverImageView.layer.shadowColor = UIColor.gray.cgColor
        self.coverImageView.layer.shadowOffset = CGSize(width: 3, height: 5)
        self.coverImageView.layer.shadowOpacity = 1
        self.coverImageView.layer.shadowRadius = 1.0
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
