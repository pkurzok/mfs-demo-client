//
//  AddCarController.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 27.04.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import Eureka

class AddCarController : FormViewController {
    
    var vendor: Vendor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initForm()
        self.addBarItem()
    }
}

extension AddCarController {
    
    @objc private func createCar() {
     
        let values = form.values()
        
        if let
            vendor = self.vendor,
            brand = values["brand"] as? String,
            model = values["model"] as? String,
            color = values["color"] as? String,
            horsepower = values["horsePower"] as? Int,
            year = values["year"] as? Int
        {
            SyncUtil().createCarForVendor(vendor, brand: brand, model: model, color: color, horsepower: horsepower, year: year)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func addBarItem() {
        let button = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(AddCarController.createCar))
        self.navigationItem.setRightBarButtonItem(button, animated: true)
    }
    
    private func initForm() {
        
        form +++ Section("Add new Car")
            <<< TextRow("brand") {
                $0.title = "Brand"
                $0.placeholder = "Brand"
            }
            
            <<< TextRow("model") {
                $0.title = "Model"
                $0.placeholder = "Model"
            }
            
            <<< SegmentedRow<String>("color") {
                $0.title = "Color"
                $0.options = ["Yellow", "Green", "Blue", "Black", "White"] }
            
            <<< IntRow("horsePower") {
                $0.title = "Horsepower"
                //$0.useFormatterOnDidBeginEditing = true
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .NumberPad
            }
            
            <<< IntRow("year") {
                $0.title = "Year"
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .NumberPad
        }
    }
}