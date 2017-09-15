//
//  MainViewController.swift
//  bucketList3
//
//  Created by Andrew Lau on 9/13/17.
//  Copyright © 2017 Andrew Lau. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation


class MainViewController: UITableViewController, AddItemDel{


    var bucket = [Tasks]()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    override func viewDidLoad() {
        super.viewDidLoad()
        findAllItems()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bucket.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bucketCell", for: indexPath)
        cell.textLabel?.text = bucket[indexPath.row].name!
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem"{
            let navigationController = segue.destination as! UINavigationController
            let addItemViewController = navigationController.topViewController as! AddItemViewController
            addItemViewController.delegate = self
            
            if let indexPath = sender{
                let index = indexPath as! NSIndexPath
                let item = bucket[index.row]
            
                addItemViewController.indexPath = index
                addItemViewController.item = item.name!
                addItemViewController.navigationItem.title = "Edit"
            }
        }
    }
    
    func cancelButtonPressed(by controller: AddItemViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func savePressedbutton(by controller: AddItemViewController, with item: String, from indexPath: NSIndexPath?) {
        if let index = indexPath{
            let items = bucket[index.row]
            items.name = item
        }
        else{
            let items = NSEntityDescription.insertNewObject(forEntityName: "Tasks", into: managedObjectContext) as! Tasks
            items.name = item
            bucket.append(items)
        }
        do {
            try managedObjectContext.save()
        } catch {
            print ("\(error)")
        }

        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "AddItem", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete =  UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let item = self.bucket[indexPath.row]
            self.managedObjectContext.delete(item)
            
            do{
                try self.managedObjectContext.save()
            } catch {
                print("\(error)")
                
            }
            self.bucket.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.performSegue(withIdentifier: "AddItem", sender: indexPath)
        }
        edit.backgroundColor = UIColor.blue
        return [delete, edit]
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddItem", sender: nil)
    }
    
    func findAllItems() {
        let itemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        do {
            let results = try managedObjectContext.fetch(itemRequest)
            bucket = results as! [Tasks]
            
        } catch {
            print("\(error)")
        }
    }
}
