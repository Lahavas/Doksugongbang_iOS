//
//  SetUpViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 24..
//  Copyright © 2017년 yeon. All rights reserved.
//

///////////////////////////////////////////
//  수정 필요한 부분
//
//  1. 여기 스플래시 넣었을 경우 MyPage 수정
//
///////////////////////////////////////////

import UIKit
import UserNotifications

class SetUpViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var userNameTextField: UITextField!
    
    @IBOutlet var alarmTimeTextField: UITextField!
    @IBOutlet var alarmCheckButton: UIButton!
    @IBOutlet var alarmSettingButton: UIButton!
    
    // MARK: User Config
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    // MARK: Extras
    
    let notificationHelper = UserNotificationHelper.shared
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alarmTimeTextField.delegate = self
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        self.alarmTimeTextField.inputView = timePicker
        timePicker.addTarget(self,
                             action: #selector(self.datePickerValueChanged(_:)),
                             for: .valueChanged)
        
        self.setUpDoneButton()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func setUpDoneButton() {
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.barStyle = .default
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "확인",
                                         style: .done,
                                         target: self,
                                         action: #selector(self.doneDatePickerPressed(_:)))
        
        toolBar.setItems([space, doneButton], animated: false)
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
    }
    
    @IBAction func setUpButton(_ sender: UIButton) {
        
        if self.userNameTextField.text == "" {
            
            let alertController: UIAlertController =
                UIAlertController(title: "이름을 입력해주세요", message: nil, preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        } else {
            
            guard
                let userName: String = self.userNameTextField.text,
                let alarmTime: String = self.alarmTimeTextField.text else {
                    preconditionFailure("Unexpected alarm time")
            }
            
            let isAlarmChecked: Bool = self.alarmCheckButton.isSelected
            
            userDefaults.set(userName, forKey: "userName")
            userDefaults.set(isAlarmChecked, forKey: "isAlarmChecked")
            userDefaults.set(alarmTime, forKey: "alarmTime")
            
            guard let appDelegate = UIApplication.shared.delegate! as? AppDelegate else {
                preconditionFailure("Unexpected AppDelegate")
            }
            
            guard let startController = self.storyboard?.instantiateViewController(withIdentifier: "StartController") as? UITabBarController else {
                preconditionFailure("Cannot found StartController")
            }
            
            appDelegate.window?.rootViewController = startController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
}

// MARK: -

extension SetUpViewController: UITextFieldDelegate {
    
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
