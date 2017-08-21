//
//  BookLogListViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 21..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class BookLogListViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var bookLogTableView: UITableView!
    
    var bookLogList: [BookLog]!
    
    var dateSectionList: [String]!
    var bookLogListInSections: [[BookLog]]!
    
    let realm = try! Realm()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bookLogTableView.delegate = self
        self.bookLogTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpBookLogList()
        self.bookLogTableView.reloadData()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func setUpBookLogList() {
        
        self.bookLogList = realm.objects(BookLog.self).sorted(byKeyPath: "dateUpdated", ascending: false).toArray()
        
        self.dateSectionList = []
        self.bookLogListInSections = [[]]
        var index: Int = -1
        
        for bookLog in self.bookLogList {
            
            if
                let bookLogDate = bookLog.value(forKey: "dateUpdated") as? Date {
                let bookLogDateString = self.dateFormatter.string(from: bookLogDate)
                
                if !(self.dateSectionList.contains(bookLogDateString)) {
                    self.dateSectionList.append(bookLogDateString)
                    index += 1
                }
                
                self.bookLogListInSections[index].append(bookLog)
            }
        }
    }
}

extension BookLogListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dateSectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookLogListInSections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dateSectionList[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "BookLogListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BookLogListTableViewCell else {
            preconditionFailure("The dequeued cell is not an instance of BookLogListTableViewCell.")
        }
        
        let bookLogListInSection = self.bookLogListInSections[indexPath.section]
        let bookLog: BookLog = bookLogListInSection[indexPath.row]
        guard
            let bookInfo: BookInfo = bookLog.parentBookInfo,
            let book: Book = bookInfo.parentBook else {
                preconditionFailure("Unexpected realm model")
        }
        
        cell.startPageLabel.text = "\(bookLog.startPage)p"
        cell.endPageLabel.text = "\(bookLog.endPage)p"
        
        cell.bookTitleLabel.text = book.title
        cell.bookReadCountLabel.text = "\(bookInfo.bookReadCount)독차"
        cell.bookLogLabel.text = bookLog.logContent
        
        return cell
    }
}
