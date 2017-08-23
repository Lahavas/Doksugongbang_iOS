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
//  2. UX적인 부분 검토 (키패드 창, Picker View 등등...)
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
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    var bookTotalPage: Int = 0
    var bookReadingPage: Int = 0
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initBookInfo()
        
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
                let startPageNumber: NSNumber = self.numberFormatter.number(from: startPageString) else {
                    preconditionFailure("Unexpected Start Page")
            }
            
            guard
                let endPageString: String = self.endPageTextField.text,
                let endPageNumber: NSNumber = self.numberFormatter.number(from: endPageString) else {
                    preconditionFailure("Unexpected End Page")
            }
            
            bookLog.startPage = startPageNumber.intValue
            bookLog.endPage = endPageNumber.intValue
            bookLog.logContent = bookLogTextView.text
            
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
        
        self.startPageTextField.text = "\(self.bookReadingPage)"
        self.endPageTextField.text = "\(self.bookReadingPage)"
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
            let pageNumber: NSNumber = self.numberFormatter.number(from: pageString) else {
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
                let startPageNumber: NSNumber = self.numberFormatter.number(from: startPageString) else {
                    preconditionFailure("Unexpected Start Page")
            }
            
            guard
                let endPageString: String = self.endPageTextField.text,
                let endPageNumber: NSNumber = self.numberFormatter.number(from: endPageString) else {
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
