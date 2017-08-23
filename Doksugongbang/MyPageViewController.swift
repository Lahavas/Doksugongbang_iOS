//
//  MyPageViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 23..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class MyPageViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var alarmTimeTextField: UITextField!
    @IBOutlet var alarmCheckButton: UIButton!
    @IBOutlet var alarmSettingButton: UIButton!
    
    @IBOutlet var favoriteBookCountLabel: UILabel!
    @IBOutlet var readingBookCountLabel: UILabel!
    @IBOutlet var readBookCountLabel: UILabel!
    
    // MARK: Models
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH시 mm분"
        return dateFormatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "내 정보"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpBookCount()
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
        case "ShowMyBookPage":
            print("Show My Book Page")
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }

    // MARK: - Methods
    
    func setUpBookCount() {
        
        let favoriteBookList = realm.objects(Book.self).filter("isFavorite = True").toArray()
        let readingBookList = realm.objects(Book.self).filter("bookState = 'reading'").toArray()
        let readBookList = realm.objects(Book.self).filter("bookState = 'read'").toArray()
        
        self.favoriteBookCountLabel.text = "\(favoriteBookList.count)권"
        self.readingBookCountLabel.text = "\(readingBookList.count)권"
        self.readBookCountLabel.text = "\(readBookList.count)권"
    }
    
    // MARK: - Actions
    
    @IBAction func showMyBook(_ sender: UIButton) {
    
        self.performSegue(withIdentifier: "ShowMyBookPage", sender: self)
    }
}
