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
import CoreMotion

class FindSmoothAirViewController : PagedViewControllerBase, DataCollectionManagerDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    let _apiWebProxy = APIWebProxy();
    
    var _lastDownloadedDateTime = NSDate();
    
    var _lastLocation: CLLocation!;
    
    let _downloadInterval = 5.0;
    
    let _downloadDistance = 5.0; // Nautical miles
    
    override func viewDidLoad() {
        DataCollectionManager.sharedInstance.startCollection(self);
    }
    
    func requestAccess(controller: UIAlertController) {
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func receivedUpdate(lastLocation: CLLocation!, accelerometerData: CMAccelerometerData!){
        if let location = lastLocation {
            self.getTurbulenceData(location);
            if(_lastLocation == nil){
                timeLabel.text = "Waiting for data...";
            } else {
                let timeSinceLastUpdate = NSDate().timeIntervalSinceDate(_lastDownloadedDateTime);
                timeLabel.text = String(format:"%.2f", location.distanceFromLocation(_lastLocation) * ConfigurationConstants.NauticalMilesPerMeter) + "nm and " + timeSinceLastUpdate.timerString + " since last update";
            }
        }
        
        if let thisAccelerometerData = accelerometerData {
            /*
            xLabel.text = String(format:"%.2f", thisAccelerometerData.acceleration.x);
            yLabel.text = String(format:"%.2f", thisAccelerometerData.acceleration.y);
            zLabel.text = String(format:"%.2f", thisAccelerometerData.acceleration.z);
            */
        }
    }
    
    private func getTurbulenceData(location: CLLocation){
        if(IJReachability.isConnectedToNetwork()){
            if(NSDate().timeIntervalSinceDate(_lastDownloadedDateTime).minute >= _downloadInterval || _lastLocation == nil || (location.distanceFromLocation(_lastLocation) * ConfigurationConstants.NauticalMilesPerMeter) >= _downloadDistance){
                
                let latString = String(format:"%f", location.coordinate.latitude);
                let lonString = String(format:"%f", location.coordinate.longitude);
                
                var urlWithParams = APIURLConstants.GetTurbulenceStatistic.sub("[latitude]", with: latString).sub("[longitude]", with: lonString).sub("[radius]", with: String(format:"%f", self._downloadDistance));
                
                _apiWebProxy.get("", url: urlWithParams, getCompleted: { (succeeded, msg, json) -> () in
                    if(succeeded) {
                        if let parseJSON = json {
                            if let responseCode = parseJSON["ResponseCode"]?.integerValue {
                                // If successful
                                if(responseCode == ResponseCodes.Success){
                                    self._lastLocation = location;
                                    self._lastDownloadedDateTime = NSDate();
                                    
                                    println(parseJSON);
                                }
                            }
                        }
                    }
                });
            }
        }
    }
}