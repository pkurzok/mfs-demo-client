//
//  SyncUtil.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 29.03.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import MagicalRecord

class SyncUtil: NSObject {
    
    // MARK: Cars
    func deleteCar(vendor: Vendor, car: Car) {
        
        MagicalRecord.saveWithBlock({ context in
            
            print("Deleting Car in Context")
            
            vendor.removeCar(car)
            car.MR_deleteEntityInContext(context)
            
            }, completion: { (success, error) in
                
                HttpUtil.sharedInstance.deleteCar(car, callback: { (Void) in
                    self.getVendors()
                })
        })
    }
    
    func createCarForVendor(vendor: Vendor, brand: String, model: String, color: String, horsepower: Int, year: Int) {
        
        var car: Car?
        
        MagicalRecord.saveWithBlock({ context in
            
            print("Creating Car in Context")
            
            car = Car.MR_createEntityInContext(context)
            
            if let car = car {
                car.carId = NSUUID().UUIDString
                car.brand = brand
                car.model = model
                car.color = color
                car.horsepower = horsepower
                car.year = year
                
                if let vendorInBgContext = vendor.MR_inContext(context) {
                    vendorInBgContext.addCar(car)
                }
            }
            }, completion: { (success, error) in
                
                if let
                    car = car?.MR_inThreadContext(),
                    vendor = vendor.MR_inThreadContext()
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        HttpUtil.sharedInstance.createCar(vendor, car: car, callback: { (Void) in
                            self.getVendors()
                        })
                    })
                }
        })
    }
    
    // MARK: Vendors
    
    func createVendorWithName(name: String) {
        
        var vendor: Vendor?
        
        MagicalRecord.saveWithBlock ({ context in
            
            print("Creating Vendor in Context")
            
            vendor = Vendor.MR_createEntityInContext(context)
            
            if let vendor = vendor {
                vendor.name = name
                vendor.vendorId = NSUUID().UUIDString
            }
            }, completion: { (success, error) in
                if let vendor = vendor?.MR_inThreadContext() {
                    HttpUtil.sharedInstance.createVendor(vendor, callback: { (Void) in
                        self.getVendors()
                    })
                }
        })
    }
    
    func deleteVendor(vendor: Vendor) {
        
        MagicalRecord.saveWithBlock({ context in
        
            print("Deleting Vendor in Context")
            
            vendor.MR_deleteEntityInContext(context)
            
        }) { (success, error) in
            HttpUtil.sharedInstance.deleteVendor(vendor, callback: { (Void) in
                self.getVendors()
            })
        }
    }
    
    func getVendors() {
        
        print("Getting Vendors")
        
        HttpUtil.sharedInstance.getVendors { (vendors) in
            
            guard let jsonVendors = vendors else { return }
            
            // GET all VendorIds from JSON
            let jsonVendorIds = self.getVendorIds(jsonVendors)
            
            // DELETE all Vendors not included in the import
            self.deleteVendorsNotIn(jsonVendorIds, completion: { (Void) in
                
                // IMPORT New and UPDATE Existing
                MagicalRecord.saveWithBlock({ context in
                    
                    Vendor.MR_importFromArray(jsonVendors, inContext: context)
                    
                    }, completion: { (success, error) in
                        print("Finished Import")
                })
            })
        }
        
        
    }
}

extension SyncUtil {
    
    private func getLocalVendors() -> [String:Vendor] {
        
        var dict = [String:Vendor]()
        
        if let vendors = Vendor.MR_findAll() as? [Vendor] {
            for vendor in vendors {
                if let id = vendor.vendorId {
                    dict[id] = vendor
                }
            }
        }
        
        return dict
    }
    
    private func deleteVendorsNotIn(vendorIds:[String], completion:(Void -> Void)) {
        
        MagicalRecord.saveWithBlock({ context in
            
            let predicate = NSPredicate(format: "NOT (vendorId IN %@)", vendorIds)
            Vendor.MR_deleteAllMatchingPredicate(predicate, inContext: context)
            
        }) { (success, error) in
            completion()
        }
    }
    
    private func getVendorIds(vendorsJsonArray: [[NSObject: AnyObject]]) -> [String] {
        
        var vendorIds = [String]()
        
        for jsonVendor in vendorsJsonArray {
            
            if let vendorId = jsonVendor["id"] as? String {
                vendorIds.append(vendorId)
            }
        }
        
        return vendorIds
    }
}
