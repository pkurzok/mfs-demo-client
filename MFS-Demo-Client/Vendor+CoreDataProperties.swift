//
//  Vendor+CoreDataProperties.swift
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

extension Vendor {

    @NSManaged var name: String?
    @NSManaged var vendorId: String?
    @NSManaged var cars: NSSet?

}
