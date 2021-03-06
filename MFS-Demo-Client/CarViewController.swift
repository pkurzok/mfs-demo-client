//
//  CarViewController.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 29.03.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import UIKit
import MagicalRecord

class CarViewController: UIViewController {
    
    var vendor: Vendor?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Car")
        fetchRequest.predicate = NSPredicate(format: "vendor = %@", self.vendor!)
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "brand", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let context = NSManagedObjectContext.MR_defaultContext()
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func createCarPressed(sender: AnyObject) {
        self.showAlertView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
}

extension CarViewController {
    
    private func showAlertView() {
        let alertController = UIAlertController(title: "Create Car", message: nil, preferredStyle: .Alert)
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { (_) in
            
            if let
                brand = alertController.textFields?[0].text,
                model = alertController.textFields?[1].text,
                color = alertController.textFields?[2].text,
                horsepower = alertController.textFields?[3].text,
                year = alertController.textFields?[4].text
            {
                if let vendor = self.vendor {
                    
                    SyncUtil().createCarForVendor(vendor, brand: brand, model: model, color: color, horsepower: horsepower, year: year)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithPlaceHolder("Brand")
        alertController.addTextFieldWithPlaceHolder("Model")
        alertController.addTextFieldWithPlaceHolder("Color")
        alertController.addTextFieldWithPlaceHolder("Horsepower")
        alertController.addTextFieldWithPlaceHolder("Year")
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        // Update Cell
        if let
            brand = record.valueForKey("brand") as? String,
            model = record.valueForKey("model") as? String
        {
            cell.textLabel?.text = "\(brand) \(model)"
        }
        
        if let
            ps = record.valueForKey("horsepower") as? Int,
            color = record.valueForKey("color") as? String,
            year = record.valueForKey("year") as? Int
        {
            cell.detailTextLabel?.text = "\(year) \(color) \(ps)PS"
        }
        else {
            cell.detailTextLabel?.text = ""
        
        }
    }
}

extension UIAlertController {
    
    func addTextFieldWithPlaceHolder(placeHolder: String) {
        
        self.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = placeHolder
        }
    }
}

extension CarViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("carCell", forIndexPath: indexPath)
        
        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if let
                vendor = self.vendor,
                car = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Car
            {
                SyncUtil().deleteCar(vendor, car: car)
            }
        }
    }
}

extension CarViewController: UITableViewDelegate {
    
    
}

extension CarViewController: NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    configureCell(cell, atIndexPath: indexPath)
                }
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
