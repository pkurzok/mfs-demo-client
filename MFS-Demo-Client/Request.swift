//
//  Request.swift
//  MFS-Demo-Client
//
//  Created by Peter Kurzok on 15.04.16.
//  Copyright © 2016 PRODYNA AG. All rights reserved.
//

import Foundation
import Alamofire
import Haneke

class Request: NSObject, NSCoding {
    
    var method: Alamofire.Method
    var url: String
    var params: [String:AnyObject]?
    
    init (method: Alamofire.Method, url: String, params: [String: AnyObject]?) {
        
        self.method = method
        self.url = url
        self.params = params
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let rawMethod = decoder.decodeObjectForKey("method") as? String,
            let url = decoder.decodeObjectForKey("url") as? String
        else { return nil }
        
        let method = Alamofire.Method(rawValue: rawMethod)!
        let params = decoder.decodeObjectForKey("params") as? [String: AnyObject]
        
        self.init(method: method, url: url, params: params)
    }

    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(self.method.rawValue, forKey: "method")
        coder.encodeObject(self.url, forKey: "url")
        coder.encodeObject(self.params, forKey: "params")
    }    
}
