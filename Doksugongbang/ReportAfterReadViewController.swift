//
//  ReportAfterReadViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit
import MobileCoreServices

class ReportAfterReadViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var pubdateLabel: UILabel!
    
    @IBOutlet var ratingControl: RatingControl!
    
    @IBOutlet var reportTextView: UITextView!
    
    // MARK: Model
    
    var book: Book!
    
    let store: BookStore = BookStore.shared
    
    // MARK: Report Text View Configuration
    
    var reportEdgeInset: UIEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
    var reportPlaceHolder: String = "이 책의 감상평을 적어주세요!"
    var reportTextColor: UIColor = UIColor.black
    var reportPlaceHolderColor: UIColor = UIColor.lightGray
    
    // MARK: CloudKit
    
    let container = CKContainer.default()
    var publicDatabase: CKDatabase!
    var currentRecord: CKRecord!
    var recordId: CKRecordID!
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reportTextView.textContainerInset = self.reportEdgeInset
        self.reportTextView.delegate = self
        
        self.publicDatabase = container.publicCloudDatabase
        self.recordId = CKRecordID(recordName: "\(UUID().uuidString)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpBookImage()
        self.setUpMainView()
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func readingAction(_ sender: UIButton) {
        
        if self.reportTextView.text == "" || self.reportTextView.text == self.reportPlaceHolder {
            
            let alertController: UIAlertController =
                UIAlertController(title: "이 책의 감상평을 적어주세요", message: nil, preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        } else if self.ratingControl.rating == 0 {
            
            let alertController: UIAlertController =
                UIAlertController(title: "이 책의 평점을 매겨주세요", message: nil, preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        } else {
        
            try! realm.write {
                
                guard let bookInfo = self.book.bookInfos.filter("bookReadCount = \(self.book.bookReadCount)").first else {
                    preconditionFailure("Cannot find bookInfo")
                }
                
                self.book.bookStateEnum = .read
                self.book.dateUpdatedBookState = Date()
                
                bookInfo.reportAfterReading = self.reportTextView.text
                bookInfo.bookRating = self.ratingControl.rating
                
                realm.add(self.book, update: true)
                
                self.uploadBookFeedInCloudKit(bookInfo)
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
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
            
            self.reportTextView.text = self.reportPlaceHolder
            self.reportTextView.textColor = self.reportPlaceHolderColor
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
    
    func uploadBookFeedInCloudKit(_ bookInfo: BookInfo) {
        
        let bookFeedRecord = CKRecord(recordType: CloudKitConfig.bookFeedRecordType, recordID: recordId)
        
        guard let userName = UserDefaults.standard.string(forKey: "userName") else {
            preconditionFailure("User Defaults is empty!")
        }
        
        bookFeedRecord.setObject(userName as CKRecordValue, forKey: "userName")
        bookFeedRecord.setObject(self.book.title as CKRecordValue, forKey: "bookTitle")
        bookFeedRecord.setObject(bookInfo.reportAfterReading as CKRecordValue, forKey: "bookReport")
        bookFeedRecord.setObject(bookInfo.bookRating as CKRecordValue, forKey: "bookRating")
        bookFeedRecord.setObject(self.book.isbn as CKRecordValue?, forKey: "bookIsbn")
        
        let modifyRecordOperation = CKModifyRecordsOperation(recordsToSave: [bookFeedRecord], recordIDsToDelete: nil)
        
        modifyRecordOperation.timeoutIntervalForRequest = 10
        modifyRecordOperation.timeoutIntervalForResource = 10
        
        modifyRecordOperation.modifyRecordsCompletionBlock = {
            (records, recordIDs, error) -> Void in
            
            self.currentRecord = bookFeedRecord
        }
        
        publicDatabase.add(modifyRecordOperation)
    }
}

// MARK: -

extension ReportAfterReadViewController: UITextViewDelegate {
    
    // MARK: - Text View Delegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = self.reportPlaceHolder
            textView.textColor = self.reportPlaceHolderColor
        }
        
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == self.reportPlaceHolder {
            textView.text = ""
            textView.textColor = self.reportTextColor
        }
        
        textView.becomeFirstResponder()
    }
}

