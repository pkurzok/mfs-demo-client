//
//  Car+CoreDataProperties.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 14.04.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Car {

    @NSManaged var brand: String?
    @NSManaged var carId: String?
    @NSManaged var color: String?
    @NSManaged var horsepower: NSNumber?
    @NSManaged var model: String?
    @NSManaged var year: NSNumber?
    @NSManaged var vendor: Vendor?

}
