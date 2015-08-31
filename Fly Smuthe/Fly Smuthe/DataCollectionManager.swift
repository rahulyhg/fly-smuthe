//
//  DataCollectionManager.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/27/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreMotion

class DataCollectionManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager();
    let motionManager = CMMotionManager();
    
    var latestTurbulenceDataState: TurbulenceStatisticModel!;
    
    var delegate: DataCollectionManagerDelegate!;
    
    class var sharedInstance: DataCollectionManager {
        struct Singleton {
            static let instance = DataCollectionManager()
        }
        return Singleton.instance;
    }
    
    func startCollection(delegate: DataCollectionManagerDelegate){
        self.delegate = delegate;
        
        locationManager.delegate = self;
        motionManager.startAccelerometerUpdates();
        
        evaluateAccess();
    }
    
    func evaluateAccess() {
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.AuthorizedAlways:
            locationManager.startUpdatingLocation();
        case CLAuthorizationStatus.NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case CLAuthorizationStatus.AuthorizedWhenInUse, CLAuthorizationStatus.Restricted, CLAuthorizationStatus.Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to provide anonymous, automatic turbulence 'PIREPs', please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.delegate.requestAccess(alertController);
            
            if(CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse){
                locationManager.startUpdatingLocation();
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            locationManager.startUpdatingLocation();
        } else {
            evaluateAccess();
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let theseLocations = locations;
        
        var xAccel: Double!;
        var yAccel: Double!;
        var zAccel: Double!;
        var altitude: Int!;
        var latitude: Double!;
        var longitude: Double!;
        var weakLocation: CLLocation!;
        var weakAccelData: CMAccelerometerData!;
        
        var hasLocationData = false;
        var hasAccelData = false;
        
        if let location = (locations.last as? CLLocation) {
            altitude = Int(location.altitude);
            latitude = location.coordinate.latitude;
            longitude = location.coordinate.longitude;
            weakLocation = location;
            hasLocationData = true;
        }
        
        
        if let currentAccelValues = motionManager.accelerometerData{
            weakAccelData = currentAccelValues;
            xAccel = currentAccelValues.acceleration.x;
            yAccel = currentAccelValues.acceleration.y;
            zAccel = currentAccelValues.acceleration.z;
            hasAccelData = true;
        }
        
        if let strongDelegate = self.delegate{
            strongDelegate.receivedUpdate(weakLocation, accelerometerData: weakAccelData);
        }
        
        var newTurbulenceDataState = TurbulenceStatisticModel(xAccel: xAccel, yAccel: yAccel, zAccel: zAccel, altitude: altitude, latitude: latitude, longitude: longitude);
        if((latestTurbulenceDataState == nil && hasLocationData && hasAccelData) || (latestTurbulenceDataState != nil && latestTurbulenceDataState.hasNotableChange(newTurbulenceDataState))){
            latestTurbulenceDataState = newTurbulenceDataState;
            
            TurbulenceStatisticRepository.sharedInstance.save(latestTurbulenceDataState);
        }
    }
}

protocol DataCollectionManagerDelegate {
    func requestAccess(controller: UIAlertController);
    
    func receivedUpdate(lastLocation: CLLocation!, accelerometerData: CMAccelerometerData!);
}