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
    
    @IBOutlet weak var gpsLabel: UILabel!
    
    @IBOutlet weak var xLabel: UILabel!
    
    @IBOutlet weak var yLabel: UILabel!
    
    @IBOutlet weak var zLabel: UILabel!
    
    override func viewDidLoad() {
        DataCollectionManager.sharedInstance.startCollection(self);
    }
    
    func requestAccess(controller: UIAlertController) {
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func receivedUpdate(lastLocation: CLLocation!, accelerometerData: CMAccelerometerData!){
        if let location = lastLocation {
            gpsLabel.text = String(format:"%f", location.coordinate.latitude) + " " + String(format:"%f", location.coordinate.longitude);
        }
        if let thisAccelerometerData = accelerometerData {
            xLabel.text = String(format:"%.2f", thisAccelerometerData.acceleration.x);
            yLabel.text = String(format:"%.2f", thisAccelerometerData.acceleration.y);
            zLabel.text = String(format:"%.2f", thisAccelerometerData.acceleration.z);
        }
    }
}