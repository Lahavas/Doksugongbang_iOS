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
    
    @IBOutlet var bookTitleTextField: UITextField!
    @IBOutlet var startPageTextField: UITextField!
    @IBOutlet var endPageTextField: UITextField!
    
    @IBOutlet var bookLogTextView: UITextView!
    
    let realm = try! Realm()
    
    var book: Book!
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.book = self.realm.objects(Book.self).filter("bookState = 'reading'").sorted(byKeyPath: "dateUpdatedBookState", ascending: false).first
        
        self.bookTitleTextField.text = self.book.title
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
    
    // 이 부분 많이 수정 (Integer 관리, numberFormatter 수정)
    @IBAction func addBookLog(_ sender: UIButton) {
        
        try! realm.write {
            
            let bookLog: BookLog = BookLog()
            
            guard let bookInfo = self.book.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first else {
                preconditionFailure("Cannot find bookInfo")
            }
            
            bookLog.startPage = (numberFormatter.number(from: startPageTextField.text!)?.intValue)!
            bookLog.endPage = (numberFormatter.number(from: endPageTextField.text!)?.intValue)!
            bookLog.logContent = bookLogTextView.text
            
            bookInfo.bookReadingPage = bookLog.endPage
            bookInfo.bookLogs.append(bookLog)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
