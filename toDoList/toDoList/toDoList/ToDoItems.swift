//
//  ToDoItems.swift
//  toDoList
//
//  Created by Brad Ehrlich on 3/21/20.
//  Copyright © 2020 Brad Ehrlich. All rights reserved.
//

import Foundation
import UserNotifications

class ToDoItems{
    var itemsArray: [ToDoItem] = []
    
    func saveData(){
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(itemsArray)
        do{
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch{
            print("Error could not save Data")
        }
        setNotifications()
    }
    func loadData(completed: @escaping ()->() ){
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")

        guard let data = try? Data(contentsOf: documentURL) else{return}
        let jsonDecoder = JSONDecoder()
        do {
            itemsArray = try jsonDecoder.decode(Array<ToDoItem>.self, from: data)
        } catch{
            print("Error could not load Data")
        }
        completed()
    }
    func setNotifications(){
        guard itemsArray.count > 0 else {
            return
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for index in 0..<itemsArray.count{
            if itemsArray[index].reminderSet{
                let toDoItem = itemsArray[index]
                itemsArray[index].notificationID = localNotificationManager.setCalendarNotifiation(title: toDoItem.name, subtitle: "", body: toDoItem.notes, badgeNumber: nil, sound: .default, date: toDoItem.date)
            }
        }
    }
}
