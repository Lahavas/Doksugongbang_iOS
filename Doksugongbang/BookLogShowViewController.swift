//
//  BookLogShowViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 24..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

class BookLogShowViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var startPageLabel: UILabel!
    @IBOutlet var endPageLabel: UILabel!
    
    @IBOutlet var bookTitleLabel: UILabel!
    @IBOutlet var bookReadCountLabel: UILabel!
    @IBOutlet var bookLogLabel: UILabel!
    
    // MARK: Model
    
    var bookLog: BookLog!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpBookLogView()
    }

    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func setUpBookLogView() {
        
        guard
            let bookInfo: BookInfo = self.bookLog.parentBookInfo,
            let book: Book = bookInfo.parentBook else {
                preconditionFailure("Unexpected realm model")
        }
        
        self.startPageLabel.text = "\(self.bookLog.startPage)p"
        self.endPageLabel.text = "\(self.bookLog.endPage)p"
        
        self.bookTitleLabel.text = book.title
        self.bookReadCountLabel.text = "\(bookInfo.bookReadCount)독차"
        self.bookLogLabel.text = self.bookLog.logContent
    }

    // MARK: - Actions
    
    @IBAction func okButtonAction(_ sender: UIButton) {
    
        self.dismiss(animated: true, completion: nil)
    }
}
