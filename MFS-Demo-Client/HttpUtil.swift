//
//  HttpUtil.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 21.03.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import UIKit
import Alamofire

class HttpUtil{
    
    static let sharedInstance = HttpUtil()
    
    private init() {
        
        ReachabilityUtil.sharedInstance.listeners.append(self)
    }
    
    let defaultManager: Alamofire.Manager = {
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "cockpit-dev.prodyna.com": .PinCertificates(
                certificates: ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: false
            ),
            
            "10.3.0.249": .PinCertificates(
                certificates: ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: false
            ),
            
            "localhost": .PinCertificates(
                certificates: ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: false
            )
        ]
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        return Alamofire.Manager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()

    // MARK: Vendors
    
    func getVendors(completion: (vendors: [[NSObject: AnyObject]]?) -> Void) {
        
        defaultManager.request(.GET, "https://localhost:8443/vendors").responseJSON { response in
            
            guard let result = response.result.value as? [[NSObject: AnyObject]] where response.result.isSuccess else {return}
            
            completion(vendors: result)
        }
    }
    
    func createVendor(vendor: Vendor, callback: (Void -> Void)) {
    
        print("Creating Vendor on Server")
        
        let url = "https://localhost:8443/vendors/"
        let params = vendor.toJson()
        
        self.request(.POST, url: url, params: params, callback: callback)
    }
    
    func deleteVendor(vendor: Vendor, callback: (Void -> Void)) {
        
        print("Deleting Vendor on Server")
        
        let url = "https://localhost:8443/vendors/\(vendor.vendorId!)"
        
        self.request(.DELETE, url: url, params: nil, callback: callback)
    }
    
    func updateVendor(vendor: Vendor, callback: (Void -> Void)) {
        
    }
    
    // MARK: Cars
    
    func createCar(vendor: Vendor, car: Car, callback: (Void -> Void)) {
        
        print("Creating Car on Server")
        
        let jsonCar = car.toJson()
        let url = "https://localhost:8443/vendors/\(vendor.vendorId!)/createCar"
        
        self.request(.POST, url: url, params: jsonCar, callback: callback)
    }
    
    
    func deleteCar(car: Car, callback: (Void -> Void)) {
        
        print("Deleting Car on Server")
        
        let url = "https://localhost:8443/cars/\(car.carId!)"
        
        self.request(.DELETE, url: url, params: nil, callback: callback)        
    }
}

extension HttpUtil: ReachabilityListener {
    
    func reachabilityChanged(isReachable: Bool) {
        
        print("HttpUitl Reachable \(isReachable)")
        
        // When returning Online process request Queue
        guard isReachable else { return }
        
        while CacheUtil.sharedInstance.hasCachedRequests() {
            
            let request = CacheUtil.sharedInstance.popRequest()
            self.defaultManager.request(request.method, request.url, parameters: request.params, encoding: .JSON)
        }
        
        // When finished, trigger Reload
        SyncUtil().getVendors()
    }
}

extension HttpUtil {
    
    private func request(method: Alamofire.Method, url: String, params: [String: AnyObject]?, callback: (Void -> Void)?) {
        
        // When Online, send request
        if ReachabilityUtil.sharedInstance.isReachable() {
            defaultManager.request(method, url, parameters: params, encoding: .JSON).responseJSON { responese in
                if let callback = callback {
                    callback()
                }
            }
        }
        // When Offline, enqueue request
        else {
            CacheUtil.sharedInstance.cacheRequest(method, url: url, params: params)
        }
    }
}

