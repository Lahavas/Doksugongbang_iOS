//
//  BookLogDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class BookLogDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var startPageTextField: UITextField!
    @IBOutlet var endPageTextField: UITextField!
    
    @IBOutlet var bookReadProgressView: UIProgressView!
    @IBOutlet var firstPageLabel: UILabel!
    @IBOutlet var lastPageLabel: UILabel!
    
    @IBOutlet var bookLogTextView: UITextView!
    
    // MARK: Model
    
    var book: Book!
    var bookInfo: BookInfo!
    
    // MARK: Log Text View Configuration
    
    var bookLogEdgeInset: UIEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
    var bookLogPlaceHolder: String = "이 책의 북 로그를 적어주세요!"
    var bookLogTextColor: UIColor = UIColor.black
    var bookLogPlaceHolderColor: UIColor = UIColor.lightGray
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    var bookTotalPage: Int = 0
    var bookReadingPage: Int = 0
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initBookInfo()
        
        self.bookLogTextView.textContainerInset = self.bookLogEdgeInset
        self.bookLogTextView.delegate = self
        
        self.startPageTextField.delegate = self
        self.endPageTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpBookLogView()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func addBookLog(_ sender: UIButton) {
        
        guard
            let startPageString: String = self.startPageTextField.text?.removeCharacters(from: "쪽"),
            let startPageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: startPageString) else {
                preconditionFailure("Unexpected Start Page")
        }
        
        guard
            let endPageString: String = self.endPageTextField.text?.removeCharacters(from: "쪽"),
            let endPageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: endPageString) else {
                preconditionFailure("Unexpected End Page")
        }
        
        if startPageNumber.intValue > endPageNumber.intValue {
            
            let alertController: UIAlertController =
                UIAlertController(title: "잘못된 값을 입력하였습니다", message: "시작 페이지보다 높은 값을 입력해주세요", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        } else if self.bookLogTextView.text == "" || self.bookLogTextView.text == self.bookLogPlaceHolder {
            
            let alertController: UIAlertController =
                UIAlertController(title: "북 로그를 입력해주세요", message: nil, preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        } else {
            
            try! realm.write {
                
                let bookLog: BookLog = BookLog()
                
                bookLog.startPage = startPageNumber.intValue
                bookLog.endPage = endPageNumber.intValue
                bookLog.logContent = bookLogTextView.text
                bookLog.dateUpdated = Date()
                bookLog.dateString = CustomDateFormatter.longType.string(from: Date())
                
                if self.bookInfo.bookReadingPage < bookLog.endPage {
                    self.bookInfo.bookReadingPage = bookLog.endPage
                }
                
                bookLog.parentBookInfo = self.bookInfo
                self.bookInfo.bookLogs.append(bookLog)
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    func initBookInfo() {
        
        if let bookInfo: BookInfo = self.book.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first {
            self.bookInfo = bookInfo
            self.bookTotalPage = bookInfo.bookTotalPage
            self.bookReadingPage = bookInfo.bookReadingPage
                
            let progressRating: Float = Float(bookInfo.bookReadingPage) / Float(bookInfo.bookTotalPage)
            self.bookReadProgressView.setProgress(progressRating, animated: true)
            
            self.firstPageLabel.text = "0쪽"
            self.lastPageLabel.text = "\(bookInfo.bookTotalPage)쪽"
        } else {
            preconditionFailure("Cannot find bookInfo")
        }
    }
    
    func setUpBookLogView() {
        
        self.titleLabel.text = self.book.title
        
        self.startPageTextField.text = "\(self.bookReadingPage)쪽"
        self.endPageTextField.text = "\(self.bookReadingPage)쪽"
        
        self.bookLogTextView.text = self.bookLogPlaceHolder
        self.bookLogTextView.textColor = self.bookLogPlaceHolderColor
    }
}

// MARK: -

extension BookLogDetailViewController: UITextFieldDelegate {
 
    // MARK: - Text Field Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard
            let pageString: String = textField.text?.removeCharacters(from: "쪽"),
            let pageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: pageString) else {
                textField.text = "\(self.bookReadingPage)쪽"
                return
        }
        
        if pageNumber.intValue > self.bookTotalPage {
            
            let alertController: UIAlertController =
                UIAlertController(title: "입력 범위를 초과했습니다", message: "\(self.bookTotalPage) 이하의 값을 입력해주세요.", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true) { 
                () -> Void in
                
                textField.text = "\(self.bookReadingPage)쪽"
            }
        } else {
            textField.text = "\(pageNumber)쪽"
        }
    }
}

// MARK: -

extension BookLogDetailViewController: UITextViewDelegate {
    
    // MARK: - Text View Delegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = self.bookLogPlaceHolder
            textView.textColor = self.bookLogPlaceHolderColor
        }
        
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == self.bookLogPlaceHolder {
            textView.text = ""
            textView.textColor = self.bookLogTextColor
        }
        
        textView.becomeFirstResponder()
    }
}
