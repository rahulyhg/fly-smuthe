//
//  FindSmoothAirViewController.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/27/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class FindSmoothAirViewController : PagedViewControllerBase, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager();
    
    override func viewDidLoad() {
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
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            if(CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse){
                locationManager.startUpdatingLocation();
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            locationManager.startUpdatingLocation();
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let theseLocations = locations;
    }
}