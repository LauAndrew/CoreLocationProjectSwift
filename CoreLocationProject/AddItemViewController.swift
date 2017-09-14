//
//  AddItemViewController.swift
//  bucketList3
//
//  Created by Andrew Lau on 9/13/17.
//  Copyright © 2017 Andrew Lau. All rights reserved.
//

import UIKit


class AddItemViewController: UITableViewController {

    
    @IBOutlet weak var nameField: UITextField!
    
    var delegate: AddItemDel?
    var item: String?
    var indexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = item
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonPressed(by: self)
    }
    
    @IBAction func savePressedButton(_ sender: UIBarButtonItem) {
        delegate?.savePressedbutton(by: self, with: nameField.text!, from: indexPath)
    }
}
