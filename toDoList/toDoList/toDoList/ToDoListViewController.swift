//
//  ViewController.swift
//  toDoList
//
//  Created by Brad Ehrlich on 2/10/20.
//  Copyright © 2020 Brad Ehrlich. All rights reserved.
//

import UIKit
import UserNotifications

class ToDoListViewController: UIViewController {
    

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var toDoItems: [ToDoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        authorizeLocalNotifications()
    }
    
    func setNotifications(){
        guard toDoItems.count > 0 else {
            return
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for index in 0..<toDoItems.count{
            if toDoItems[index].reminderSet{
                let toDoItem = toDoItems[index]
                toDoItems[index].notificationID = setCalendarNotifiation(title: toDoItem.name, subtitle: "", body: toDoItem.notes, badgeNumber: nil, sound: .default, date: toDoItem.date)
            }
        }
    }
    
    func setCalendarNotifiation(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound?, date: Date) -> String {
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
    
    func authorizeLocalNotifications() {
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
            }
        }
    }
    
    func loadData(){
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: documentURL) else{return}
        let jsonDecoder = JSONDecoder()
        do {
            toDoItems = try jsonDecoder.decode(Array<ToDoItem>.self, from: data)
            tableView.reloadData()
        } catch{
            print("Error could not load Data")
        }
    }
    
    func saveData(){
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(toDoItems)
        do{
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch{
            print("Error could not save Data")
        }
        setNotifications()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let destination = segue.destination as! ToDoDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = toDoItems[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
        
    }

    @IBAction func unwindFromDetail(segue: UIStoryboardSegue){
        let source = segue.source as! ToDoDetailTableViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            toDoItems[selectedIndexPath.row] = source.toDoItem
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: toDoItems.count, section: 0)
            toDoItems.append(source.toDoItem)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        saveData()
    }

    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    }
}
extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource, ListTableViewCellDelegate{
    func checkBoxToggled(sender: ListTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            toDoItems[selectedIndexPath.row].completed = !toDoItems[selectedIndexPath.row].completed
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        cell.delegate = self
        cell.nameLabel.text = toDoItems[indexPath.row].name
        cell.checkBoxButton.isSelected = toDoItems[indexPath.row].completed
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            toDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = toDoItems[sourceIndexPath.row]
        toDoItems.remove(at: sourceIndexPath.row)
        toDoItems.insert(itemToMove, at: destinationIndexPath.row)
        saveData()
    }
    
    
}
