//
//  CacheUtil.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 15.04.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess

class CacheUtil {
    
    static let sharedInstance = CacheUtil()
    private let keychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier!)
    private let kRequests = "requestsKey"
    
    private init() {}
    
    func cacheRequest(method: Alamofire.Method, url: String, params: [String: AnyObject]?) {
     
        let rq = Request(method: method, url: url, params: params)
        self.cacheRequest(rq)
    }
    
    func cacheRequest(request: Request) {
        var requests = self.getRequests()
        requests.append(request)
        self.saveRequests(requests)
    }
    
    func hasCachedRequests() -> Bool {
        let requests = self.getRequests()
        return requests.count > 0
    }
    
    func popRequest() -> Request {
        var requests = self.getRequests()
        let request = requests.removeFirst()
        self.saveRequests(requests)
        return request
    }
}

extension CacheUtil {
    
    private func getRequests() -> [Request] {
        
        do {
            if let
                data = try self.keychain.getData(kRequests),
                requests = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Request]
            {
                return requests
            } else {
                return [Request]()
            }
        } catch {
            print("Error reading Requuests")
            return [Request]()
        }
    }
    
    private func saveRequests(requests: [Request]) {
        
        do {
            let data = NSKeyedArchiver.archivedDataWithRootObject(requests)
            try self.keychain.set(data, key: kRequests)
        } catch {
            print("Error saving Requests")
        }
    }
}