//
//  FindSmoothAirViewController.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/27/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import UIKit

class FindSmoothAirViewController : PagedViewControllerBase, DataCollectionManagerDelegate {
    
    override func viewDidLoad() {
        DataCollectionManager.sharedInstance.startCollection(self);
    }
    
    func requestAccess(controller: UIAlertController) {
        self.presentViewController(controller, animated: true, completion: nil);
    }
}