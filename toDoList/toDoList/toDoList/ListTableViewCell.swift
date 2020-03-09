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
    
    weak var delegate: ListTableViewCellDelegate?

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func checkToggled(_ sender: UIButton) {
        delegate?.checkBoxToggled(sender: self)
    }
    
}
