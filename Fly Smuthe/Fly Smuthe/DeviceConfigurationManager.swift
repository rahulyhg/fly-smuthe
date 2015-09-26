//
//  DeviceConfigurationManager.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/7/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class DeviceConfigurationManager {
    
    class var sharedInstance: DeviceConfigurationManager {
        struct Singleton {
            static let instance = DeviceConfigurationManager()
        }
        return Singleton.instance;
    }
    
    func getAPICredential() -> String{
        return getAccessId() + ":" + getAccessKey();
    }
    
    func saveAccessKey(accessKey: String){
        if(accessKey.characters.count == 0){
            UYLPasswordManager.sharedInstance().deleteKeyForIdentifier(SecurityConstants.AccessKeyApplicationTag);
            return;
        }
        
        UYLPasswordManager.sharedInstance().registerKey(accessKey, forIdentifier: SecurityConstants.AccessKeyApplicationTag);
    }
    
    func hasAccessKey() -> Bool {
        let accessKey = UYLPasswordManager.sharedInstance().keyForIdentifier(SecurityConstants.AccessKeyApplicationTag);
        return accessKey != nil && accessKey.characters.count > 0;
    }
    
    func getAccessKey() -> String {
        let accessKey = UYLPasswordManager.sharedInstance().keyForIdentifier(SecurityConstants.AccessKeyApplicationTag);
        if(accessKey == nil){
            return "";
        }
        return accessKey;
    }
    
    func saveAccessId(accessId: String){
        if(accessId.characters.count == 0){
            UYLPasswordManager.sharedInstance().deleteKeyForIdentifier(SecurityConstants.AccessIdApplicationTag);
            return;
        }
        UYLPasswordManager.sharedInstance().registerKey(accessId, forIdentifier: SecurityConstants.AccessIdApplicationTag);
    }
    
    func hasAccessId() -> Bool {
        let accessId = UYLPasswordManager.sharedInstance().keyForIdentifier(SecurityConstants.AccessIdApplicationTag);
        return accessId != nil && accessId.characters.count > 0;
    }
    
    func getAccessId() -> String {
        let accessId = UYLPasswordManager.sharedInstance().keyForIdentifier(SecurityConstants.AccessIdApplicationTag);
        if(accessId == nil){
            return "";
        }
        return accessId;
    }
}