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
//  1. StartPage, EndPage 제약조건 (Delegate를 통해 Max값 체크해주고 stargPage <= endPage)
//
//  2. 진행률 ProgressBar 두기
//
//  3. UX적인 부분 검토 (키패드 창, Picker View 등등...)
//
//
///////////////////////////////////////////

import UIKit
import RealmSwift

class BookLogDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var bookTitleTextField: UITextField!
    @IBOutlet var startPageTextField: UITextField!
    @IBOutlet var endPageTextField: UITextField!
    
    @IBOutlet var bookLogTextView: UITextView!
    
    let realm = try! Realm()
    
    var book: Book!
    var bookList: [Book]!
    var bookInfo: BookInfo!
    
    var bookTotalPage: Int = 0
    var bookReadingPage: Int = 0
    var bookTitlePickOption: [String] = []
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.minimum = 0
        return numberFormatter
    }()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initBookInfo()
        
        let bookTitlePickerView = UIPickerView()
        bookTitlePickerView.delegate = self
        self.bookTitleTextField.inputView = bookTitlePickerView
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
                let startPageString: String = startPageTextField.text,
                let startPageNumber: NSNumber = numberFormatter.number(from: startPageString) else {
                    preconditionFailure("Unexpected Start Page")
            }
            
            guard
                let endPageString: String = endPageTextField.text,
                let endPageNumber: NSNumber = numberFormatter.number(from: endPageString) else {
                    preconditionFailure("Unexpected End Page")
            }
            
            bookLog.startPage = startPageNumber.intValue
            bookLog.endPage = endPageNumber.intValue
            bookLog.logContent = bookLogTextView.text
            
            if self.bookInfo.bookReadingPage < bookLog.endPage {
                self.bookInfo.bookReadingPage = bookLog.endPage
            }
            self.bookInfo.bookLogs.append(bookLog)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Methods
    
    func initBookInfo() {
        
        self.bookList = self.realm
            .objects(Book.self)
            .filter("bookState = 'reading'")
            .sorted(byKeyPath: "dateUpdatedBookState", ascending: false)
            .toArray()
        
        for book in bookList {
            self.bookTitlePickOption.append(book.title)
        }
        
        if
            let firstBook: Book = bookList.first,
            let bookInfo: BookInfo = firstBook.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first {
            self.book = firstBook
            self.bookInfo = bookInfo
            self.bookTotalPage = bookInfo.bookTotalPage
            self.bookReadingPage = bookInfo.bookReadingPage
        } else {
            preconditionFailure("Cannot find bookInfo")
        }
    }
    
    func setUpBookLogView() {
        
        self.bookTitleTextField.text = self.book.title
        self.startPageTextField.text = String(self.bookReadingPage)
        self.endPageTextField.text = String(self.bookReadingPage)
        
        self.numberFormatter.maximum = self.bookTotalPage as NSNumber
    }
}

// MARK: -

extension BookLogDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Picker View Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bookTitlePickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bookTitlePickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.view.endEditing(true)
        
        let bookTitle: String = bookTitlePickOption[row]
        
        if
            let selectedBook: Book = realm.objects(Book.self).filter("title = '\(bookTitle)'").first,
            let bookInfo: BookInfo = selectedBook.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first {
            self.book = selectedBook
            self.bookInfo = bookInfo
            self.bookTotalPage = bookInfo.bookTotalPage
            self.bookReadingPage = bookInfo.bookReadingPage
        } else {
            preconditionFailure("Cannot find bookInfo")
        }
        
        self.setUpBookLogView()
    }
}

