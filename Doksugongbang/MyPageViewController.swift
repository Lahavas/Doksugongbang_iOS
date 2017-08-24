//
//  MyPageViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 23..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

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
    
    // MARK: User Config
    
    var isAlarmChecked: Bool = false
    var name: String = "홍길동"
    var alarmTime: String = "오전 07시 00분"
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    let notificationHelper = UserNotificationHelper.shared
    
    let dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh시 mm분"
        dateFormatter.amSymbol = "오전"
        dateFormatter.pmSymbol = "오후"
        return dateFormatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "내 정보"
        
        UNUserNotificationCenter.current().delegate = self
        self.alarmTimeTextField.delegate = self
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        self.alarmTimeTextField.inputView = timePicker
        timePicker.addTarget(self,
                             action: #selector(self.datePickerValueChanged(_:)),
                             for: .valueChanged)
        
        self.setUpDoneButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpUserConfig()
        self.setUpBookCount()
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
    
    func setUpUserConfig() {
        
        self.userNameLabel.text = "\(self.name)님! 환영합니다"
        
        self.alarmCheckButton.isSelected = self.isAlarmChecked
        self.alarmTimeTextField.text = self.alarmTime
    }
    
    func setUpBookCount() {
        
        let favoriteBookList = realm.objects(Book.self).filter("isFavorite = True").toArray()
        let readingBookList = realm.objects(Book.self).filter("bookState = 'reading'").toArray()
        let readBookList = realm.objects(Book.self).filter("bookState = 'read'").toArray()
        
        self.favoriteBookCountLabel.text = "\(favoriteBookList.count)권"
        self.readingBookCountLabel.text = "\(readingBookList.count)권"
        self.readBookCountLabel.text = "\(readBookList.count)권"
    }
    
    func setUpDoneButton() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "확인",
                                         style: .done,
                                         target: self,
                                         action: #selector(self.doneDatePickerPressed(_:)))
        doneButton.tintColor = UIColor.black
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        self.alarmTimeTextField.inputAccessoryView = toolBar
    }
    
    // MARK: - Actions
    
    @IBAction func checkAlarm(_ sender: UIButton) {
        
        guard
            let alarmTimeString = alarmTimeTextField.text,
            let alarmTime = dateFormatter.date(from: alarmTimeString) else {
            preconditionFailure("Unexpected alarm time")
        }
        
        let alarmCalendar: Calendar = Calendar.current
        
        let alarmHour: Int = alarmCalendar.component(.hour, from: alarmTime)
        let alarmMinute: Int = alarmCalendar.component(.minute, from: alarmTime)
        
        if self.alarmCheckButton.isSelected {
            
            self.alarmCheckButton.isSelected = false
            
            self.notificationHelper.removeScheduleUserNotification()
        } else {
            
            self.alarmCheckButton.isSelected = true
            
            self.notificationHelper.center.getNotificationSettings {
                (notificationSettings) -> Void in
                
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    
                    self.notificationHelper.requestAuthorization() {
                        (success) -> Void in
                        
                        guard success else {
                            return
                        }
                        
                        self.notificationHelper.scheduleUserNotification(alarmHour: alarmHour,
                                                                         alarmMinute: alarmMinute)
                    }
                case .authorized:
                
                    self.notificationHelper.scheduleUserNotification(alarmHour: alarmHour,
                                                                     alarmMinute: alarmMinute)
                case .denied:
                    print("Application Not Allowed to Display Notifications")
                }
            }
        }
    }
    
    @IBAction func setUpAlarmTime(_ sender: UIButton) {
    
        self.alarmTimeTextField.becomeFirstResponder()
    }
    
    func doneDatePickerPressed(_ sender: UIBarButtonItem) {
        
        self.view.endEditing(true)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        
        self.alarmTimeTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func showMyBook(_ sender: UIButton) {
    
        self.performSegue(withIdentifier: "ShowMyBookPage", sender: self)
    }
}

// MARK: -

extension MyPageViewController: UITextFieldDelegate {
    
    // MARK: - Text Field Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard
            let alarmTimeString = alarmTimeTextField.text,
            let alarmTime = dateFormatter.date(from: alarmTimeString) else {
                preconditionFailure("Unexpected alarm time")
        }
        
        let alarmCalendar: Calendar = Calendar.current
        
        let alarmHour: Int = alarmCalendar.component(.hour, from: alarmTime)
        let alarmMinute: Int = alarmCalendar.component(.minute, from: alarmTime)
        
        if self.alarmCheckButton.isSelected {
            
            self.notificationHelper.center.getNotificationSettings {
                (notificationSettings) -> Void in
                
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    
                    self.notificationHelper.requestAuthorization() {
                        (success) -> Void in
                        
                        guard success else {
                            return
                        }
                        
                        self.notificationHelper.scheduleUserNotification(alarmHour: alarmHour,
                                                                         alarmMinute: alarmMinute)
                    }
                case .authorized:
                    
                    self.notificationHelper.scheduleUserNotification(alarmHour: alarmHour,
                                                                     alarmMinute: alarmMinute)
                case .denied:
                    print("Application Not Allowed to Display Notifications")
                }
            }
        }
    }
}

// MARK: -

extension MyPageViewController: UNUserNotificationCenterDelegate {
    
    // MARK: - User Notification Center Delegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert])
    }
}

