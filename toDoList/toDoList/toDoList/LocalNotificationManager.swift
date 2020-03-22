//
//  LocalNotificationManager.swift
//  toDoList
//
//  Created by Brad Ehrlich on 3/21/20.
//  Copyright © 2020 Brad Ehrlich. All rights reserved.
//

import UIKit
import UserNotifications

struct localNotificationManager {
    
    static func authorizeLocalNotifications(viewController: UIViewController) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
            guard error == nil else {
                print("Error")
                return
            }
            if granted{
                print("Granted")
            }
            else{
                print("Denied")
                DispatchQueue.main.async {
                    viewController.oneButtonAlert(title: "User has not Allowed Notifications", message: "Change in settings")
                }
                
            }
        }
    }
    
    static func isAuthorized(completed: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
            guard error == nil else {
                print("Error")
                completed(false)
                return
            }
            if granted{
                print("Granted")
                completed(true)
            }
            else{
                print("Denied")
                completed(false)
            }
        }
    }
    
    static func setCalendarNotifiation(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound?, date: Date) -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badgeNumber
        content.sound = sound
        
        var dateCompontents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        dateCompontents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompontents, repeats: false)
        
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Notification Scheduled \(notificationID), title: \(content.title)")
            }
        }
        return notificationID
    }

    
    
}
