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

class FindSmoothAirViewController : PagedViewControllerBase, DataCollectionManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    let _apiWebProxy = APIWebProxy();
    
    let _downloadInterval = 5.0;
    
    let _downloadDistance = 5.0; // Nautical miles
    
    private var refreshControl: UIRefreshControl;
    
    private var _lastDownloadedDateTime = NSDate();
    
    private var _lastLocation: CLLocation!;
    
    private var _turbulenceLocationSummaries = [TurbulenceLocationSummaryDTO]();
    
    private let TurbulenceLocationSummaryDataCellCellIdentifier = "TurbulenceLocationSummaryDataCellCellIdentifier";
    
    private var isLoadingData = false;
    
    required init(coder aDecoder: NSCoder)
    {
        refreshControl = UIRefreshControl();
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        DataCollectionManager.sharedInstance.startCollection(self);
        
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged);
        tableView.addSubview(refreshControl);
        
        tableView.registerClass(TurbulenceLocationSummaryDataCell.self, forCellReuseIdentifier: TurbulenceLocationSummaryDataCellCellIdentifier);
        let nib = UINib(nibName: "TurbulenceLocationSummaryDataCell", bundle: nil);
        tableView.registerNib(nib, forCellReuseIdentifier: TurbulenceLocationSummaryDataCellCellIdentifier);
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh(sender: AnyObject){
        if(_lastLocation != nil){
            self.getTurbulenceData(self._lastLocation, forceLoad: true);
        }
        self.refreshControl.endRefreshing();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _turbulenceLocationSummaries.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(TurbulenceLocationSummaryDataCellCellIdentifier) as! TurbulenceLocationSummaryDataCell;
        
        let obj = _turbulenceLocationSummaries[indexPath.row];
        
        cell.altitudeLabel.text = String(obj.Altitude) + "ft";
        cell.descriptionLabel.text = obj.Description;
        cell.frequencyLabel.text = String(format:"%.2f", obj.BumpsPerMinute) + "bpm";
        
        if(Int(round(Double(_lastLocation.altitude) / 100.0) * 100) == obj.Altitude){
            cell.altitudeLabel.font = UIFont.boldSystemFontOfSize(cell.altitudeLabel.font.pointSize);
            cell.descriptionLabel.font = UIFont.boldSystemFontOfSize(cell.altitudeLabel.font.pointSize);
            cell.frequencyLabel.font = UIFont.boldSystemFontOfSize(cell.altitudeLabel.font.pointSize);
        }
        
        if(obj.Accuracy < 50){
            cell.backgroundColor = UIColor(white: 0.667, alpha: 0.3);
        } else if(obj.IntensityRating == IntensityRatingConstants.Smooth){
            cell.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.3);
        } else if(obj.IntensityRating == IntensityRatingConstants.Light){
            cell.backgroundColor = UIColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 0.3);
        } else if(obj.IntensityRating == IntensityRatingConstants.Moderate){
            cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3);
        } else if(obj.IntensityRating == IntensityRatingConstants.Severe){
            cell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3);
        } else if(obj.IntensityRating == IntensityRatingConstants.Extreme){
            cell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5);
        }
    
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65;
    }

    func requestAccess(controller: UIAlertController) {
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func receivedUpdate(lastLocation: CLLocation!, accelerometerData: CMAccelerometerData!){
        if let location = lastLocation {
            self.getTurbulenceData(location, forceLoad: false);
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
    
    private func getTurbulenceData(location: CLLocation, forceLoad: Bool){
        if(IJReachability.isConnectedToNetwork() && !isLoadingData){
            
            isLoadingData = true;
            
            if((NSDate().timeIntervalSinceDate(_lastDownloadedDateTime).minute >= _downloadInterval || _lastLocation == nil || (location.distanceFromLocation(_lastLocation) * ConfigurationConstants.NauticalMilesPerMeter) >= _downloadDistance) || forceLoad){
                
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
                                    
                                    self._turbulenceLocationSummaries = [TurbulenceLocationSummaryDTO]();
                                    
                                    if let results = parseJSON["Results"] as? NSArray{
                                        for var index = 0; index < results.count; ++index {
                                            if let thisResult = results[index] as? NSDictionary {
                                                self._turbulenceLocationSummaries.append(TurbulenceLocationSummaryDTO(altitude: thisResult["Altitude"]!.integerValue!, averageIntensity: thisResult["AverageIntensity"]!.doubleValue!, bumps: thisResult["Bumps"]!.integerValue!, bumpsPerMinute: thisResult["BumpsPerMinute"]!.doubleValue!, description: thisResult["Description"]! as! String, minutes: thisResult["Minutes"]!.doubleValue!, intensityRating: thisResult["IntensityRating"]!.integerValue!, radius: thisResult["Radius"]!.integerValue!, accuracy: thisResult["Accuracy"]!.integerValue!));
                                            }
                                        }
                                        
                                        ThreadUtility.runOnMainThread(){
                                            self.reloadTableView();
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    self.isLoadingData = false;
                });
            } else {
                self.isLoadingData = false;
            }
        }
    }
    
    private func reloadTableView(){
        self.tableView.reloadData();
        /*
        self.tableView.beginUpdates();
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates();
        */
    }
}