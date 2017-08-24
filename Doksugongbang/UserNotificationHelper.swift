//
//  UserNotificationHelper.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 24..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class UserNotificationHelper: NSObject {
    
    // MARK: - Properties
    
    let center = UNUserNotificationCenter.current()
    
    static let shared = UserNotificationHelper()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    let yesterday: Date = {
        
        guard let yesterday: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            preconditionFailure("Cannot known today")
        }
        
        return yesterday
    }()

    // MARK: - Methods
    
    func requestAuthorization(completion: @escaping (_ success: Bool) -> Void) {
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (success, error) -> Void in
            
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completion(success)
        }
    }
    
    func removeScheduleUserNotification() {
        
        center.removeAllPendingNotificationRequests()
    }
    
    func scheduleUserNotification(alarmHour hour: Int, alarmMinute minute: Int) {
        
        let realm = try! Realm()
        
        let yesterdayBookLogCount: Int = realm
            .objects(BookLog.self)
            .filter("dateString = '\(dateFormatter.string(from: self.yesterday))'")
            .toArray()
            .count
        
        print(yesterdayBookLogCount)
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.body = "어제 기록한 북 로그 : \(yesterdayBookLogCount)개"
        
        var dateInfo = DateComponents()
        dateInfo.hour = hour
        dateInfo.minute = minute
        
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: "alarm_notification",
                                                        content: notificationContent,
                                                        trigger: notificationTrigger)
        
        center.removeAllPendingNotificationRequests()
        
        center.add(notificationRequest) {
            (error) -> Void in
            
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
}
