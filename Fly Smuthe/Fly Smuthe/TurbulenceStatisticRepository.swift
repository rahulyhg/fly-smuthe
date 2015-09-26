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
        let entityTurbulenceStatistic = NSEntityDescription.insertNewObjectForEntityForName(TurbulenceStatisticProperties.EntityName, inManagedObjectContext: self.context) ;
        entityTurbulenceStatistic.setValue(turbulenceStatistic.XAccel, forKey: TurbulenceStatisticProperties.XAccelKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.YAccel, forKey: TurbulenceStatisticProperties.YAccelKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.ZAccel, forKey: TurbulenceStatisticProperties.ZAccelKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.Altitude, forKey: TurbulenceStatisticProperties.AltitudeKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.Latitude, forKey: TurbulenceStatisticProperties.LatitudeKey);
        entityTurbulenceStatistic.setValue(turbulenceStatistic.Longitude, forKey: TurbulenceStatisticProperties.LongitudeKey);
        entityTurbulenceStatistic.setValue(NSDate(), forKey: TurbulenceStatisticProperties.CreatedKey);
        
        self.saveDelegate.saveContext();
    }
    
    func getAll() -> [AnyObject]?{
        let request = NSFetchRequest(entityName: TurbulenceStatisticProperties.EntityName);
        var error: NSError? = nil;
        
        do {
            return try self.context.executeFetchRequest(request)
        } catch _ {
            return nil
        };
    }
    
    func delete(obj: NSManagedObject){
        self.context.deleteObject(obj);
    }
    
    func saveContext() {
        self.saveDelegate.saveContext();
    }
}

protocol TurbulenceStatisticRepositorySaveDelegate : class {
    func saveContext();
}