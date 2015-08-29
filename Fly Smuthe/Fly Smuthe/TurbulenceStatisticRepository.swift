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
 
    func setContextAndSaveDelegate(context: NSManagedObjectContext, saveDelegate: TurbulenceStatisticRepositorySaveDelegate){
        self.context = context;
        self.saveDelegate = saveDelegate;
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
        ThreadUtility.runOnBackgroundPriorityBackgroundThread(){
            if(IJReachability.isConnectedToNetwork()){
                // Sync unsynced data to API

                let request = NSFetchRequest(entityName: TurbulenceStatisticProperties.EntityName);
                var error: NSError? = nil;
                
                let results = self.context.executeFetchRequest(request, error: &error);
                
                if let resultList = results {
                    if(resultList.count > 0) {
                        for result in resultList {
                            
                            self.context.deleteObject(result as! NSManagedObject);
                        }
                    }
                }
                
                self.saveDelegate.saveContext();
            }
            
            // Recursive call to startBackgroundSync every 20 seconds
            ThreadUtility.delay(20){
                ThreadUtility.runOnMainThread(){
                    self.startBackgroundSync();
                }
            }
        }
    }
}

protocol TurbulenceStatisticRepositorySaveDelegate : class {
    func saveContext();
}