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
    var bookInfo: BookInfo!
    var bookLogList: [BookLog]!
    
    var bookReadCount: Int = 0
    var bookReadCountPickOption: [String] = []
    
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
        
        self.initBookInfo()
        
        self.bookLogTableView.delegate = self
        self.bookLogTableView.dataSource = self
        
        let readCountPickerView = UIPickerView()
        readCountPickerView.delegate = self
        self.bookCountTextField.inputView = readCountPickerView
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
    
    func initBookInfo() {
        
        if let bookInfo = self.book.bookInfos.sorted(byKeyPath: "bookReadCount", ascending: false).first {
            self.bookInfo = bookInfo
        } else {
            preconditionFailure("Cannot find bookInfo")
        }
        
        bookReadCount = self.bookInfo.bookReadCount
        
        for readCount in 1...bookReadCount {
            let readCountString: String = "\(readCount)독차"
            self.bookReadCountPickOption.append(readCountString)
        }
        
        self.bookLogList = self.bookInfo.bookLogs.sorted(byKeyPath: "dateUpdated", ascending: false).toArray()
    }
    
    func setUpDetailView() {
        
        self.bookCountTextField.text = "\(bookReadCount)독차"
        self.bookRating.rating = self.bookInfo.bookRating
        self.bookReportAfterReadLabel.text = self.bookInfo.reportAfterReading
        self.bookReportBeforeReadLabel.text = self.bookInfo.reportBeforeReading
        
        self.setUpBookLogList()
        self.bookLogTableView.reloadData()
    }
    
    func setUpBookLogList() {
        
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

// MARK: -

extension BookReportDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Picker View Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bookReadCountPickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bookReadCountPickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.view.endEditing(true)
        
        self.bookCountTextField.text = bookReadCountPickOption[row]
        self.bookReadCount = row + 1
        if let bookInfo = self.book.bookInfos.filter("bookReadCount = \(self.bookReadCount)").first {
            self.bookInfo = bookInfo
            self.bookLogList = self.bookInfo.bookLogs.sorted(byKeyPath: "dateUpdated", ascending: false).toArray()
        } else {
            preconditionFailure("Cannot find bookInfo")
        }
        
        self.setUpDetailView()
    }
}

// MARK: -

extension BookReportDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        let identifier = "BookLogTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BookLogTableViewCell else {
            preconditionFailure("The dequeued cell is not an instance of BookLogTableViewCell.")
        }
        
        let bookLogListInSection = self.bookLogListInSections[indexPath.section]
        let bookLog: BookLog = bookLogListInSection[indexPath.row]
        
        cell.startPageLabel.text = "\(bookLog.startPage)"
        cell.endPageLabel.text = "\(bookLog.endPage)"
        cell.bookLogLabel.text = bookLog.logContent
        
        return cell
    }
}
