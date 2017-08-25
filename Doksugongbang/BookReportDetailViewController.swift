//
//  BookReportDetailViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

///////////////////////////////////////////
//  수정 필요한 부분
//
//  1. ScrollView 적용
//
///////////////////////////////////////////

class BookReportDetailViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    // Book Header
    
    @IBOutlet var bookCountTextField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    
    // Book Report After Read
    
    @IBOutlet var bookRating: RatingControl!
    @IBOutlet var bookReportAfterReadLabel: UILabel!
    
    // Book Report Before Read
    
    @IBOutlet var bookReportBeforeReadLabel: UILabel!
    
    // Views
    
    @IBOutlet var bookReportView: UIView!
    @IBOutlet var bookReportAfterView: UIView!
    @IBOutlet var bookReportBeforeView: UIView!
    @IBOutlet var bookLogTableView: UITableView!
    
    // MARK: Models
    
    var book: Book!
    var bookInfo: BookInfo!
    var bookLog: BookLog!
    var bookLogList: [BookLog]!
    
    var bookReadCount: Int = 0
    var bookReadCountPickOption: [String] = []
    
    var dateSectionList: [String]!
    var bookLogListInSections: [[BookLog]]!
    
    // MARK: Extra
    
    let realm = try! Realm()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initBookInfo()
        
        self.title = "책 기록"
        
        self.bookLogTableView.delegate = self
        self.bookLogTableView.dataSource = self
        
        self.bookLogTableView.rowHeight = UITableViewAutomaticDimension
        self.bookLogTableView.estimatedRowHeight = 140.0
        
        let readCountPickerView = UIPickerView()
        readCountPickerView.delegate = self
        self.bookCountTextField.inputView = readCountPickerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpBookReportView()
        self.setUpBookLogList()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowLogDetail":
            guard let bookLogShowViewController = segue.destination as? BookLogShowViewController else {
                preconditionFailure("Unexpected Segue Destination")
            }
            
            bookLogShowViewController.bookLog = self.bookLog
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    // MARK: - Methods
    
    func initBookInfo() {
        
        self.titleLabel.text = self.book.title
        
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
    
    func setUpBookReportView() {
        
        self.bookCountTextField.text = "\(bookReadCount)독차"
        
        self.bookRating.rating = self.bookInfo.bookRating
        
        if self.bookInfo.bookRating == 0 {
            self.bookReportAfterReadLabel.text = "아직 책을 다 읽지 않았습니다!"
        } else {
            self.bookReportAfterReadLabel.text = self.bookInfo.reportAfterReading
        }
        
        self.bookReportBeforeReadLabel.text = self.bookInfo.reportBeforeReading
        
        self.setUpBookLogList()
    }
    
    func setUpBookLogList() {
        
        self.dateSectionList = []
        self.bookLogListInSections = [[]]
        var index: Int = -1
        
        for bookLog in self.bookLogList {
            
            if
                let bookLogDate = bookLog.value(forKey: "dateUpdated") as? Date {
                let bookLogDateString = CustomDateFormatter.mediumType.string(from: bookLogDate)
                
                if !(self.dateSectionList.contains(bookLogDateString)) {
                    self.dateSectionList.append(bookLogDateString)
                    index += 1
                }
                
                self.bookLogListInSections[index].append(bookLog)
            }
        }
        
        self.bookLogTableView.reloadData()
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
        
        self.setUpBookReportView()
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
        
        cell.startPageLabel.text = "\(bookLog.startPage)쪽"
        cell.endPageLabel.text = "\(bookLog.endPage)쪽"
        
        cell.bookTitleLabel.text = book.title
        cell.bookReadCountLabel.text = "\(bookInfo.bookReadCount)독차"
        cell.bookLogLabel.text = bookLog.logContent
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookLogListInSection = self.bookLogListInSections[indexPath.section]
        self.bookLog = bookLogListInSection[indexPath.row]
        
        self.performSegue(withIdentifier: "ShowLogDetail", sender: self)
    }
}
