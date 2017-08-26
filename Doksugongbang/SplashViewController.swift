//
//  SplashViewController.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 25..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import CloudKit

class SplashViewController: UIViewController {

    // MARK: - Properties
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectViewController()
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func selectViewController() {
        
        guard let appDelegate = UIApplication.shared.delegate! as? AppDelegate else {
            preconditionFailure("Unexpected AppDelegate")
        }

        if userDefaults.string(forKey: "userName") == nil || userDefaults.string(forKey: "alarmTime") == nil {
            
            guard let setUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SetUpViewController") as? SetUpViewController else {
                preconditionFailure("Cannot found SetUpViewController")
            }
            
            appDelegate.window?.rootViewController = setUpViewController
            appDelegate.window?.makeKeyAndVisible()
        } else {
            
            guard let startController = self.storyboard?.instantiateViewController(withIdentifier: "StartController") as? UITabBarController else {
                preconditionFailure("Cannot found StartController")
            }
            
            appDelegate.window?.rootViewController = startController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func fetchRecord(_ recordID: CKRecordID) -> Void
    {
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) {
            (record, error) -> Void in
            
            return
        }
    }
}
