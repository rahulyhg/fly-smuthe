//
//  TurbulenceStatisticRepository.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/29/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import CoreData

struct TurbulenceStatisticProperties {
    static let EntityName = "TurbulenceStatistic";
    static let XAccelKey = "x_accel";
    static let YAccelKey = "y_accel";
    static let ZAccelKey = "z_accel";
    static let AltitudeKey = "altitude";
    static let LatitudeKey = "latitude";
    static let LongitudeKey = "longitude";
    static let CreatedKey = "created";
}

class TurbulenceStatisticRepository {
    
    let MaxHoursBeforeDataStale = 4.0;
    
    init(){
        
    }
    
    class var sharedInstance: TurbulenceStatisticRepository {
        struct Singleton {
            static let instance = TurbulenceStatisticRepository()
        }
        return Singleton.instance;
    }
    
    var context: NSManagedObjectContext!;

    var saveDelegate: TurbulenceStatisticRepositorySaveDelegate!;
    
    let apiWebProxy: APIWebProxy = APIWebProxy();
    
    var isSyncing = false;
    
    var groupId = "";
 
    func setContextAndSaveDelegate(context: NSManagedObjectContext, saveDelegate: TurbulenceStatisticRepositorySaveDelegate){
        self.context = context;
        self.saveDelegate = saveDelegate;
        groupId = NSUUID().UUIDString;
    }
    
    func save(turbulenceStatistic: TurbulenceStatisticModel) {
        let entityTurbulenceStatistic = NSEntityDescription.insertNewObjectForEntityForName(TurbulenceStatisticProperties.EntityName, inManagedObjectContext: self.context) as! NSManagedObject;
        entityTurbulenceStatistic.setValue(turbulenceStatistic.XAccel, forKey: TurbulenceStatisticProperties.XAccelKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.YAccel, forKey: TurbulenceStatisticProperties.YAccelKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.ZAccel, forKey: TurbulenceStatisticProperties.ZAccelKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.Altitude, forKey: TurbulenceStatisticProperties.AltitudeKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.Latitude, forKey: TurbulenceStatisticProperties.LatitudeKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.Longitude, forKey: TurbulenceStatisticProperties.LongitudeKey);
        entityTurbulenceStatistic.setValue(NSDate(), forKey: TurbulenceStatisticProperties.CreatedKey);
        
        self.saveDelegate.saveContext();
    }
    
    func startBackgroundSync(){
        // Prevents two threads from hitting this at the same time
        if(!isSyncing){
            // Set isSyncing to true while background thread works
            isSyncing = true;
            
            ThreadUtility.runOnBackgroundPriorityBackgroundThread(){
                if(IJReachability.isConnectedToNetwork()){
                    // Sync unsynced data to API
                    let request = NSFetchRequest(entityName: TurbulenceStatisticProperties.EntityName);
                    var error: NSError? = nil;
                    
                    let results = self.context.executeFetchRequest(request, error: &error);
                    
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
                                            self.context.deleteObject(obj);
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
                                        self.apiWebProxy.post(turbulenceStatisticDTO, credential: "", url: APIURLConstants.PostTurbulenceStatistic, expectsEncryptedResponse: false, postCompleted: { (succeeded: Bool, msg: String, json: NSDictionary?) -> () in
                                            
                                            // If unsuccessful, the data will remain local and keep trying
                                            // to sync until it is stale
                                            var parsed = false;
                                            if(succeeded) {
                                                if let parseJSON = json {
                                                    if let responseCode = parseJSON["ResponseCode"]?.integerValue {
                                                        // If successful, delete the local row
                                                        if(responseCode == ResponseCodes.Success){
                                                            self.context.deleteObject(obj);
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        });
                                    } else {
                                        // There was an error reading the date, delete the data
                                        self.context.deleteObject(obj);
                                    }
                                    
                                }
                            }
                        }
                    }
                    // Finally save all the changes we made (deletions) to the local data store
                    self.saveDelegate.saveContext();
                }
                // Reset isSyncing flag to allow another round of calls
                ThreadUtility.runOnMainThread(){
                    self.isSyncing = false;
                }
            }
        }
    }
}

protocol TurbulenceStatisticRepositorySaveDelegate : class {
    func saveContext();
}