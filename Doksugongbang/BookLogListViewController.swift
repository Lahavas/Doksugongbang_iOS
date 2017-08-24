//
//  BookLogListViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 21..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

///////////////////////////////////////////
//  수정 필요한 부분
//
//  1. TableView와 SearchBar 분리 (캘린더 버튼 및 스크롤 시에 SearchBar 보이는거 유무부 설정)
//
///////////////////////////////////////////

class BookLogListViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var bookLogTableView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: Model
    
    var bookLogList: [BookLog]!

    var dateSectionList: [String]!
    var bookLogListInSections: [[BookLog]]!
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "북 로그"
        
        self.searchBar.delegate = self
        
        self.bookLogTableView.delegate = self
        self.bookLogTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.bookLogList = realm
            .objects(BookLog.self)
            .sorted(byKeyPath: "dateUpdated", ascending: false)
            .toArray()
        
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

extension BookLogListViewController: UISearchBarDelegate {
    
    // MARK: - Search Bar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchText = searchBar.text else {
            preconditionFailure("Unexpected Search Text")
        }
        
        let tempBookLogList = realm
            .objects(BookLog.self)
            .filter("logContent LIKE '*\(searchText)*'")
            .sorted(byKeyPath: "dateUpdated", ascending: false)
            .toArray()
        
        if tempBookLogList.count <= 0 {
            
            let alertController: UIAlertController =
                UIAlertController(title: "결과가 없습니다", message: nil, preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true) {
                () -> Void in
                
                searchBar.text = ""
                
                self.bookLogList = self.realm
                    .objects(BookLog.self)
                    .sorted(byKeyPath: "dateUpdated", ascending: false)
                    .toArray()
            }
        } else {
            self.bookLogList = tempBookLogList
            
            self.setUpBookLogList()
            self.bookLogTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.bookLogList = realm
            .objects(BookLog.self)
            .sorted(byKeyPath: "dateUpdated", ascending: false)
            .toArray()
        
        self.setUpBookLogList()
        self.bookLogTableView.reloadData()
        
        searchBar.text = ""
        self.view.endEditing(true)
    }
}

// MARK: -

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
