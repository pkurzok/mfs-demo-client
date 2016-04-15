//
//  ReachabilityUtil.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 15.04.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import Reachability

protocol ReachabilityListener {

    func reachabilityChanged(isReachable: Bool)
}

class ReachabilityUtil {
    
    static let sharedInstance = ReachabilityUtil()
    
    let reach: Reachability
    
    var listeners = [ReachabilityListener]()
    
    private init() {
        self.reach = Reachability.reachabilityForInternetConnection()
        
        self.reach.reachableBlock = {
            (let reach: Reachability!) -> Void in
            
            print("REACHABLE!")
            
            for listener in self.listeners {
                listener.reachabilityChanged(true)
            }
        }
        
        self.reach.unreachableBlock = {
            (let reach: Reachability!) -> Void in
            print("UNREACHABLE!")
            
            for listener in self.listeners {
                listener.reachabilityChanged(false)
            }
        }
        
        self.reach.startNotifier()
    }
    
    func isReachable() -> Bool {
        return self.reach.isReachable()
    }
}