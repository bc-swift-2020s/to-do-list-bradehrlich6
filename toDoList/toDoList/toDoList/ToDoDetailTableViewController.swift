//
//  ToDoDetailTableViewController.swift
//  toDoList
//
//  Created by Brad Ehrlich on 2/10/20.
//  Copyright © 2020 Brad Ehrlich. All rights reserved.
//

import UIKit
import UserNotifications

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

class ToDoDetailTableViewController: UITableViewController {
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    
    var toDoItem: ToDoItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        nameField.delegate = self
        
        if toDoItem == nil{
            toDoItem = ToDoItem(name: "", date: Date().addingTimeInterval(24*60*60), notes: "", reminderSet: false, completed: false)
            nameField.becomeFirstResponder()
        }
        updataeUserInterface()
    }
    
    @objc func appActiveNotification(){
        print("App is on foreground")
        updateReminderSwitch()
    }
    func updataeUserInterface(){
        nameField.text = toDoItem.name
        datePicker.date = toDoItem.date
        noteView.text = toDoItem.notes
        reminderSwitch.isOn = toDoItem.reminderSet
        dateLabel.textColor = (reminderSwitch.isOn ? .black:.gray)
        dateLabel.text = dateFormatter.string(from: toDoItem.date )
        enableDisableSaveButton(text: nameField.text!)
        updateReminderSwitch()
    }
    
    func updateReminderSwitch(){
        localNotificationManager.isAuthorized { (authorized) in
            DispatchQueue.main.async{
                if !authorized && self.reminderSwitch.isOn{
                    self.oneButtonAlert(title: "User has not Alllowed Notifications", message: "Go to settings to turn on notifications")
                    self.reminderSwitch.isOn = false
                }
                self.view.endEditing(true)
                self.dateLabel.textColor = (self.reminderSwitch.isOn ? .black:.gray)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        toDoItem = ToDoItem(name: nameField.text!, date: datePicker.date, notes: noteView.text, reminderSet: reminderSwitch.isOn, completed: toDoItem.completed)
    }
    
    func enableDisableSaveButton(text: String){
        if text.count > 0 {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func reminderSwitchChanged(_ sender: UISwitch) {
        updateReminderSwitch()
    }
    @IBAction func datePikcerChanged(_ sender: UIDatePicker) {
        self.view.endEditing(true)
        dateLabel.text = dateFormatter.string(from: sender.date)
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        enableDisableSaveButton(text: sender.text!)
    }
}
extension ToDoDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath{
        case IndexPath(row: 1, section: 1):
            return reminderSwitch.isOn ? datePicker.frame.height : 0
        case IndexPath(row: 0, section: 2):
            return 200
        default:
            return 44
            
        }
    }
}

extension ToDoDetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noteView.becomeFirstResponder()
        return true
    }
}
