//
//  AppDelegate.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Config StatusBar
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = ColorUtils.statusBar
        }
        
        UIApplication.shared.statusBarStyle = .default
        
        // Config User Notification
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (authorized, error) -> Void in
            
            if authorized {
                application.registerForRemoteNotifications()
            }
        }
        
        if let options: NSDictionary = launchOptions as NSDictionary? {
            let remoteNotification = options[UIApplicationLaunchOptionsKey.remoteNotification]
            
            if let notification = remoteNotification {
                
                self.application(application, didReceiveRemoteNotification: notification as! [AnyHashable : Any]) {
                    (result) -> Void in
                }
            }
        }
        
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
        
        let realm = try! Realm()
        
        let bookList = realm
            .objects(Book.self)
            .filter("isFavorite = True")
            .toArray()
        
        for book in bookList {
            
            guard
                let userName: String = UserDefaults.standard.string(forKey: "userName"),
                let bookIsbn: String = book.isbn else {
                    preconditionFailure("User Defaults is empty!")
            }
            
            let predicate: NSPredicate = NSPredicate(format: "bookIsbn = %@", bookIsbn)
            
            let subscription = CKQuerySubscription(recordType: CloudKitConfig.bookFeedRecordType,
                                                   predicate: predicate,
                                                   options: .firesOnRecordCreation)
            
            let notificationInfo = CKNotificationInfo()
            notificationInfo.shouldBadge = true
            notificationInfo.alertBody = "\(userName) 님께서 \(book.title) 을 읽고 감상평을 남겨주셨습니다!"
            
            subscription.notificationInfo = notificationInfo
            
            publicDatabase.save(subscription) {
                (subscription, error) -> Void in
                
                return
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let viewController: SplashViewController = self.window?.rootViewController as! SplashViewController
        
        let notification: CKNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if (notification.notificationType == CKNotificationType.query) {
            
            let queryNotification = notification as! CKQueryNotification
            
            let recordID = queryNotification.recordID
            
            viewController.fetchRecord(recordID!)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: -

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: - User Notification Center Delegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
}

