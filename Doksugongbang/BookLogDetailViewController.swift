//
//  BookLogDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

///////////////////////////////////////////
//  수정 필요한 부분
//
//  1. 진행률 ProgressBar 두기
//
///////////////////////////////////////////

import UIKit
import RealmSwift

class BookLogDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var startPageTextField: UITextField!
    @IBOutlet var endPageTextField: UITextField!
    
    @IBOutlet var bookLogTextView: UITextView!
    
    // MARK: Model
    
    var book: Book!
    var bookInfo: BookInfo!
    
    // MARK: Log Text View Configuration
    
    var reportEdgeInset: UIEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
    var reportPlaceHolder: String = "이 책의 북로그를 적어주세요!"
    var reportTextColor: UIColor = UIColor.black
    var reportPlaceHolderColor: UIColor = UIColor.lightGray
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    var bookTotalPage: Int = 0
    var bookReadingPage: Int = 0
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initBookInfo()
        
        self.bookLogTextView.textContainerInset = self.reportEdgeInset
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
        
        try! realm.write {
            
            let bookLog: BookLog = BookLog()
            
            guard
                let startPageString: String = self.startPageTextField.text,
                let startPageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: startPageString) else {
                    preconditionFailure("Unexpected Start Page")
            }
            
            guard
                let endPageString: String = self.endPageTextField.text,
                let endPageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: endPageString) else {
                    preconditionFailure("Unexpected End Page")
            }
            
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
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    func initBookInfo() {
        
        if let bookInfo: BookInfo = self.book.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first {
            self.bookInfo = bookInfo
            self.bookTotalPage = bookInfo.bookTotalPage
            self.bookReadingPage = bookInfo.bookReadingPage
        } else {
            preconditionFailure("Cannot find bookInfo")
        }
    }
    
    func setUpBookLogView() {
        
        self.titleLabel.text = self.book.title
        
        self.startPageTextField.text = "\(self.bookReadingPage)p"
        self.endPageTextField.text = "\(self.bookReadingPage)p"
        
        self.bookLogTextView.text = self.reportPlaceHolder
        self.bookLogTextView.textColor = self.reportPlaceHolderColor
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
            let pageString: String = textField.text,
            let pageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: pageString) else {
                textField.text = "\(self.bookReadingPage)"
                return
        }
        
        if pageNumber.intValue > self.bookTotalPage {
            
            let alertController: UIAlertController =
                UIAlertController(title: "입력 범위를 초과했습니다", message: "\(self.bookTotalPage) 이하의 값을 입력해주세요.", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true) { 
                () -> Void in
                
                textField.text = "\(self.bookReadingPage)"
            }
        }
        
        if self.endPageTextField == textField {
            
            guard
                let startPageString: String = self.startPageTextField.text,
                let startPageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: startPageString) else {
                    preconditionFailure("Unexpected Start Page")
            }
            
            guard
                let endPageString: String = self.endPageTextField.text,
                let endPageNumber: NSNumber = CustomNumberFormatter.decimalStyle.number(from: endPageString) else {
                    preconditionFailure("Unexpected End Page")
            }
            
            if startPageNumber.intValue > endPageNumber.intValue {
                
                let alertController: UIAlertController =
                    UIAlertController(title: "잘못된 값을 입력하였습니다", message: "시작 페이지보다 높은 값을 입력해주세요", preferredStyle: .alert)
                
                let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                
                alertController.addAction(okAction)
                
                present(alertController, animated: true) {
                    () -> Void in
                    
                    textField.text = "\(self.bookReadingPage)"
                }
            }
        }
    }
}

// MARK: -

extension BookLogDetailViewController: UITextViewDelegate {
    
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
