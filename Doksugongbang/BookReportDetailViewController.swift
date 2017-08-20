//
//  BookReportDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class BookReportDetailViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var bookLogTableView: UITableView!
    
    @IBOutlet var bookCountTextField: UITextField!
    @IBOutlet var bookRating: RatingControl!
    @IBOutlet var bookReportAfterReadLabel: UILabel!
    @IBOutlet var bookReportBeforeReadLabel: UILabel!
    
    var book: Book!
    
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bookLogTableView.delegate = self
        self.bookLogTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpDetailView()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func setUpDetailView() {

        guard let bookInfo = self.book.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first else {
            preconditionFailure("Cannot find bookInfo")
        }
        
        self.bookCountTextField.text = "\(bookInfo.bookReadCount)독차"
        self.bookRating.rating = bookInfo.bookRating
        self.bookReportAfterReadLabel.text = bookInfo.reportAfterReading
        self.bookReportBeforeReadLabel.text = bookInfo.reportBeforeReading
    }
}

// MARK: -

extension BookReportDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "BookLogTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BookLogTableViewCell else {
            preconditionFailure("The dequeued cell is not an instance of BookLogTableViewCell.")
        }
        
        return cell
    }
}
