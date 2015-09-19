//
//  SyncManager.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/19/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import CoreData

class SyncManager {
    
    let MaxHoursBeforeDataStale = 10.0;
    
    let apiWebProxy: APIWebProxy = APIWebProxy();
    
    var isSyncing = false;
    
    var groupId = "";
    
    init(){
        groupId = NSUUID().UUIDString;
    }
    
    class var sharedInstance: SyncManager {
        struct Singleton {
            static let instance = SyncManager()
        }
        return Singleton.instance;
    }
    
    func startBackgroundSync(){
        // Prevents two threads from hitting this at the same time
        if(!isSyncing){
            // Set isSyncing to true while background thread works
            isSyncing = true;
            
            ThreadUtility.runOnBackgroundPriorityBackgroundThread(){
                if(IJReachability.isConnectedToNetwork()){
                    // Sync unsynced data to API
                    let results = TurbulenceStatisticRepository.sharedInstance.getAll();
                    
                    if let resultList = results {
                        if(resultList.count > 0) {
                            for result in resultList {
                                
                                if let obj = result as? NSManagedObject {
                                    let date = obj.valueForKey(TurbulenceStatisticProperties.CreatedKey) as? NSDate;
                                    
                                    // Get the date and make sure it saved properly
                                    // Note: this probably isn't necessary, but I saw a nil exception
                                    // during debugging that indicated the date was not properly saved
                                    if(date != nil){
                                        let hoursStale = NSDate().timeIntervalSinceDate(date!).hours;
                                        // If the data is more than MaxHoursBeforeDataStale, we don't want it anymore
                                        if(hoursStale > self.MaxHoursBeforeDataStale){
                                            TurbulenceStatisticRepository.sharedInstance.delete(obj);
                                            continue;
                                        }
                                        
                                        // Get all the values we need to sync
                                        let xAccel = obj.valueForKey(TurbulenceStatisticProperties.XAccelKey)!.doubleValue!;
                                        let yAccel = obj.valueForKey(TurbulenceStatisticProperties.YAccelKey)!.doubleValue!;
                                        let zAccel = obj.valueForKey(TurbulenceStatisticProperties.ZAccelKey)!.doubleValue!;
                                        let altitude = obj.valueForKey(TurbulenceStatisticProperties.AltitudeKey)!.integerValue!;
                                        let latitude = obj.valueForKey(TurbulenceStatisticProperties.LatitudeKey)!.doubleValue!;
                                        let longitude = obj.valueForKey(TurbulenceStatisticProperties.LongitudeKey)!.doubleValue!;
                                        
                                        // Assemble DTO for syncing
                                        var turbulenceStatisticDTO = TurbulenceStatisticDTO(xAccel: xAccel, yAccel: yAccel, zAccel: zAccel, altitude: altitude, latitude: latitude, longitude: longitude, created: date!, groupId: self.groupId);
                                        
                                        // Post to web api
                                        self.apiWebProxy.post(turbulenceStatisticDTO, credential: DeviceConfigurationManager.sharedInstance.getAPICredential(), url: APIURLConstants.PostTurbulenceStatistic, expectsEncryptedResponse: false, postCompleted: { (succeeded: Bool, msg: String, json: NSDictionary?) -> () in
                                            
                                            // If unsuccessful, the data will remain local and keep trying
                                            // to sync until it is stale
                                            var parsed = false;
                                            if(succeeded) {
                                                if let parseJSON = json {
                                                    if let responseCode = parseJSON["ResponseCode"]?.integerValue {
                                                        // If successful, delete the local row
                                                        if(responseCode == ResponseCodes.Success){
                                                            TurbulenceStatisticRepository.sharedInstance.delete(obj);
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        });
                                    } else {
                                        // There was an error reading the date, delete the data
                                        TurbulenceStatisticRepository.sharedInstance.delete(obj);
                                    }
                                    
                                }
                            }
                        }
                    }
                    // Finally save all the changes we made (deletions) to the local data store
                    TurbulenceStatisticRepository.sharedInstance.saveContext();
                }
                // Reset isSyncing flag to allow another round of calls
                ThreadUtility.runOnMainThread(){
                    self.isSyncing = false;
                }
            }
        }
    }
}