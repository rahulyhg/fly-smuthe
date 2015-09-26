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
    
    let _apiWebProxy = APIWebProxy();
    
    let InaccuracyThreshold = 50;
    
    @IBOutlet weak var settingsIcon: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    private var refreshControl: UIRefreshControl;
    
    private var _lastDownloadedDateTime = NSDate();
    
    private var _lastLocation: CLLocation!;
    
    private var _currentLocation: CLLocation!;
    
    private var _turbulenceLocationSummaries = [TurbulenceLocationSummaryDTO]();
    
    private let TurbulenceLocationSummaryDataCellCellIdentifier = "TurbulenceLocationSummaryDataCellCellIdentifier";
    
    private var isLoadingData = false;
    
    private var includeInaccurateResults: Bool = true;
    
    private var radius: Int = 3;
    
    private var hoursUntilStale: Int = 3;
    
    private var intervalMin: Int = 5;
    
    var delegate: QuickSettingsViewControllerDelegate!;
    
    required init?(coder aDecoder: NSCoder)
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
        
        let settingsTap = UITapGestureRecognizer(target: self, action: Selector("settingsTapped"))
        settingsIcon.addGestureRecognizer(settingsTap)
        settingsIcon.userInteractionEnabled = true
        
        
        let viewTap = UITapGestureRecognizer(target: self, action: Selector("settingsDismissed"))
        view.addGestureRecognizer(viewTap)
        view.userInteractionEnabled = true;
    }
    
    func settingsTapped(){
        if(delegate != nil){
            delegate.settingsButtonPressed();
        }
    }
    
    func settingsDismissed(){
        if(delegate != nil){
            delegate.settingsDismissed();
            refresh(self);
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier(TurbulenceLocationSummaryDataCellCellIdentifier) as! TurbulenceLocationSummaryDataCell;
        
        let obj = _turbulenceLocationSummaries[indexPath.row];
        
        // Set text
        cell.altitudeLabel.text = String(obj.Altitude) + "ft";
        cell.descriptionLabel.text = obj.Description;
        cell.frequencyLabel.text = String(format:"%.2f", obj.BumpsPerMinute) + "bpm";
        
        // Bold current altitude
        if(Int(round(Double(_lastLocation.altitude) / 100.0) * 100) == obj.Altitude){
            cell.altitudeLabel.font = UIFont.boldSystemFontOfSize(cell.altitudeLabel.font.pointSize);
            cell.descriptionLabel.font = UIFont.boldSystemFontOfSize(cell.altitudeLabel.font.pointSize);
            cell.frequencyLabel.font = UIFont.boldSystemFontOfSize(cell.altitudeLabel.font.pointSize);
        }
        
        // Set color coding by intensity
        if(obj.Accuracy < self.InaccuracyThreshold){
            cell.backgroundColor = IntensityColorConstants.Inaccurate;
        } else if(obj.IntensityRating == IntensityRatingConstants.Smooth){
            cell.backgroundColor = IntensityColorConstants.Smooth;
        } else if(obj.IntensityRating == IntensityRatingConstants.Light){
            cell.backgroundColor = IntensityColorConstants.Light;
        } else if(obj.IntensityRating == IntensityRatingConstants.Moderate){
            cell.backgroundColor = IntensityColorConstants.Moderate;
        } else if(obj.IntensityRating == IntensityRatingConstants.Severe){
            cell.backgroundColor = IntensityColorConstants.Severe;
        } else if(obj.IntensityRating == IntensityRatingConstants.Extreme){
            cell.backgroundColor = IntensityColorConstants.Extreme;
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
                timeLabel.text = "Updated " + String(format:"%.2f", location.distanceFromLocation(_lastLocation) * ConfigurationConstants.NauticalMilesPerMeter) + "nm and " + timeSinceLastUpdate.timerString + " ago";
            }
        }
    }
    
    private func getLatestSettings(){
        if(delegate != nil){
            self.includeInaccurateResults = delegate.includeInaccurateResults;
            self.radius = delegate.radius;
            self.hoursUntilStale = delegate.hoursUntilStale;
            self.intervalMin = delegate.intervalMin;
        }
    }
    
    private func needLocationUpdate(location: CLLocation) -> Bool {
        let minutesSinceLastUpdate = NSDate().timeIntervalSinceDate(_lastDownloadedDateTime).minute;
        
        let nauticalMilesSinceLastUpdate = (location.distanceFromLocation(_lastLocation) * ConfigurationConstants.NauticalMilesPerMeter);
        
        // True when we are past the update interval, past the update radius or we don't have an update yet
        return (minutesSinceLastUpdate >= Double(self.intervalMin) || _lastLocation == nil || nauticalMilesSinceLastUpdate >= Double(self.radius));
    }
    
    private func getTurbulenceData(location: CLLocation, forceLoad: Bool){
        
        getLatestSettings();
        
        if(IJReachability.isConnectedToNetwork() && !isLoadingData){
            
            isLoadingData = true;
            
            if(self.needLocationUpdate(location) || forceLoad){
                
                let latString = String(format:"%f", location.coordinate.latitude);
                let lonString = String(format:"%f", location.coordinate.longitude);
                
                // Setup URL with rest get params
                let urlWithParams = APIURLConstants.GetTurbulenceStatistic
                    .sub("[latitude]", with: latString)
                    .sub("[longitude]", with: lonString)
                    .sub("[radius]", with: String(self.radius))
                    .sub("[hoursUntilStale]", with: String(self.hoursUntilStale));
                
                _apiWebProxy.get(DeviceConfigurationManager.sharedInstance.getAPICredential(), url: urlWithParams, getCompleted: { (succeeded, msg, json) -> () in
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
                                                if((!self.includeInaccurateResults && thisResult["Accuracy"]!.integerValue! >= self.InaccuracyThreshold) || self.includeInaccurateResults){
                                                    self._turbulenceLocationSummaries.append(TurbulenceLocationSummaryDTO(altitude: thisResult["Altitude"]!.integerValue!, averageIntensity: thisResult["AverageIntensity"]!.doubleValue!, bumps: thisResult["Bumps"]!.integerValue!, bumpsPerMinute: thisResult["BumpsPerMinute"]!.doubleValue!, description: thisResult["Description"]! as! String, minutes: thisResult["Minutes"]!.doubleValue!, intensityRating: thisResult["IntensityRating"]!.integerValue!, radius: thisResult["Radius"]!.integerValue!, accuracy: thisResult["Accuracy"]!.integerValue!));
                                                }
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
    }
}