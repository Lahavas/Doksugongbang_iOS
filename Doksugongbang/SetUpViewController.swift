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

class SetUpViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet var userNameTextField: UITextField!
    
    @IBOutlet var alarmTimeTextField: UITextField!
    @IBOutlet var alarmCheckButton: UIButton!
    @IBOutlet var alarmSettingButton: UIButton!
    
    // MARK: User Config
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    var isAlarmChecked: Bool = true
    var userName: String = "이기사"
    var alarmTime: String = "오전 07시 01분"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDefaults.set(isAlarmChecked, forKey: "isAlarmChecked")
        userDefaults.set(userName, forKey: "userName")
        userDefaults.set(alarmTime, forKey: "alarmTime")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
