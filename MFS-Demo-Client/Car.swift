//
//  Car.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 21.03.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import CoreData


class Car: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func toJson() -> [String:AnyObject] {
        
        var dict = [String:AnyObject]()

        if let brand = self.brand {
            dict["make"] = brand
        }
        if let carId = self.carId {
            dict["id"] = carId
        }
        if let color = self.color {
            dict["color"] = color
        }
        if let horsepower = self.horsepower {
            dict["horsePower"] = horsepower
        }
        if let model = self.model {
            dict["model"] = model
        }
        if let year = self.year {
            dict["year"] = year
        }
        
        return dict
    }
}
