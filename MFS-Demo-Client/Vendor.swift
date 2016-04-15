//
//  Vendor.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 21.03.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord

class Vendor: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    
    func addCar(car: Car) {
        let cars = self.mutableSetValueForKey("cars")
        cars.addObject(car)
    }

    func removeCar(car: Car) {
        let cars = self.mutableSetValueForKey("cars")
        cars.removeObject(car)
    }
    
    func toJson() -> [String:AnyObject] {
        var dict = [String:AnyObject]()
        
        if let vendorId = self.vendorId {
            dict["id"] = vendorId
        }
        if let name = self.name {
            dict["name"] = name
        }
        if let cars = self.cars {
            var carDicts = [[String:AnyObject]]()
            for car in cars {
                carDicts.append(car.toJson())
            }
            dict["cars"] = carDicts
        }
        return dict
    }
    
    // Make sure cars not included in the import will be deleted
    override func willImport(data: AnyObject) {
        
        if let
            jsonData = data as? [String:AnyObject],
            idList = jsonData["cars"]?.valueForKey("id") as? [String]
        {
            MagicalRecord.saveWithBlock { context in
                
                 print("Deleting orphaned Cars in context")
                
                let predicate = NSPredicate(format: "vendor = %@ AND NOT (carId IN %@)", self, idList)
                Car.MR_deleteAllMatchingPredicate(predicate, inContext: context)
            }
        }
    }
}
