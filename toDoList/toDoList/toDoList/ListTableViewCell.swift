//
//  ListTableViewCell.swift
//  toDoList
//
//  Created by Brad Ehrlich on 3/9/20.
//  Copyright © 2020 Brad Ehrlich. All rights reserved.
//

import UIKit

protocol ListTableViewCellDelegate: class {
    func checkBoxToggled(sender: ListTableViewCell)
}
class ListTableViewCell: UITableViewCell {
    

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: ListTableViewCellDelegate?
    
    var toDoItem: ToDoItem! {
        didSet{
            nameLabel.text = toDoItem.name
            checkBoxButton.isSelected = toDoItem.completed
        }
    }
    
    @IBAction func checkToggled(_ sender: UIButton) {
        delegate?.checkBoxToggled(sender: self)
    }
    
}
