//
//  MyPageViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 23..
//  Copyright © 2017년 yeon. All rights reserved.
//

///////////////////////////////////////////
//  수정 필요한 부분
//
//  1. Splash 화면 및 SetUpViewController 적용 시에 UserDefaults 관련 부분 전부 수정 (// Flag 오픈)
//
///////////////////////////////////////////

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
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    // Flag
    var isAlarmChecked: Bool = false
    var userName: String = "홍길동"
    var alarmTime: String = "오전 07시 00분"
    
    // MARK: Extras
    
    let realm = try! Realm()
    
    let notificationHelper = UserNotificationHelper.shared
    
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

        // Flag
//        guard
//            let isAlarmChecked = self.userDefaults.bool(forKey: "isAlarmChecked"),
//            let userName = self.userDefaults.string(forKey: "userName"),
//            let alarmTime = self.userDefaults.string(forKey: "alarmTime") else {
//                preconditionFailure("User Defaults is empty!")
//        }
//        
//        self.isAlarmChecked = isAlarmChecked
//        self.userName = userName
//        self.alarmTime = alarmTime
        
        self.userNameLabel.text = "\(self.userName)님! 환영합니다"
        
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
            let alarmTimeString = self.alarmTimeTextField.text,
            let alarmTime = CustomDateFormatter.timeType.date(from: alarmTimeString) else {
            preconditionFailure("Unexpected alarm time")
        }
        
        let alarmCalendar: Calendar = Calendar.current
        
        let alarmHour: Int = alarmCalendar.component(.hour, from: alarmTime)
        let alarmMinute: Int = alarmCalendar.component(.minute, from: alarmTime)
        
        if self.alarmCheckButton.isSelected {
            
            self.alarmCheckButton.isSelected = false
            
            // Flag
//            self.isAlarmChecked = false
//            self.userDefaults.set(self.isAlarmChecked, forKey: "isAlarmChecked")
            
            self.notificationHelper.removeScheduleUserNotification()
        } else {
            
            self.alarmCheckButton.isSelected = true
            
            // Flag
//            self.isAlarmChecked = true
//            self.userDefaults.set(self.isAlarmChecked, forKey: "isAlarmChecked")
            
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
    
    @IBAction func dismissDatePicker(_ sender: UITapGestureRecognizer) {
    
        self.view.endEditing(true)
    }
    
    @IBAction func setUpAlarmTime(_ sender: UIButton) {
    
        self.alarmTimeTextField.becomeFirstResponder()
    }
    
    func doneDatePickerPressed(_ sender: UIBarButtonItem) {
        
        self.view.endEditing(true)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        
        self.alarmTimeTextField.text = CustomDateFormatter.timeType.string(from: sender.date)
        
        // Flag
//        self.alarmTime = self.alarmTimeTextField.text
//        self.userDefaults.set(self.alarmTime, forKey: "alarmTime")
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
            let alarmTime = CustomDateFormatter.timeType.date(from: alarmTimeString) else {
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

