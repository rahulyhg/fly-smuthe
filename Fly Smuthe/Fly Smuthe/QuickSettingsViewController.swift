//
//  QuickSettingsViewController.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/7/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import UIKit

class QuickSettingsViewController : UIViewController {
    
    let standardUserDefaults = NSUserDefaults.standardUserDefaults();
    
    var delegate: QuickSettingsViewControllerDelegate!;
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var includeInaccurateResultsToggle: UISwitch!
    
    @IBOutlet weak var lookbackSelector: UISegmentedControl!
    
    @IBOutlet weak var radiusSelector: UISegmentedControl!
    
    @IBOutlet weak var intervalSelector: UISegmentedControl!
    
    
    @IBAction func radiusChanged(sender: UISegmentedControl) {
        if let strongDelegate = delegate {
            switch sender.selectedSegmentIndex {
            case 0:
                //1
                strongDelegate.radius = 1;
                break;
            case 1:
                //3
                strongDelegate.radius = 3;
                break;
            case 2:
                //5
                strongDelegate.radius = 5;
                break;
            case 3:
                //10
                strongDelegate.radius = 10;
                break;
            default:
                strongDelegate.radius = 3;
                break;
            }
        }
        standardUserDefaults.setInteger(sender.selectedSegmentIndex, forKey: SettingsConstants.RadiusKey);
        standardUserDefaults.synchronize();
    }
    
    @IBAction func lookbackChanged(sender: UISegmentedControl) {
        if let strongDelegate = delegate {
            switch sender.selectedSegmentIndex {
            case 0:
                //1
                strongDelegate.hoursUntilStale = 1;
                break;
            case 1:
                //3
                strongDelegate.hoursUntilStale = 3;
                break;
            case 2:
                //5
                strongDelegate.hoursUntilStale = 5;
                break;
            case 3:
                //10
                strongDelegate.hoursUntilStale = 10;
                break;
            default:
                strongDelegate.hoursUntilStale = 3;
                break;
            }
        }
        standardUserDefaults.setInteger(sender.selectedSegmentIndex, forKey: SettingsConstants.HoursUntilStaleKey);
        standardUserDefaults.synchronize();
    }
    
    @IBAction func intervalChanged(sender: UISegmentedControl) {
        if let strongDelegate = delegate {
            switch sender.selectedSegmentIndex {
            case 0:
                //1
                strongDelegate.intervalMin = 5;
                break;
            case 1:
                //3
                strongDelegate.intervalMin = 10;
                break;
            case 2:
                //5
                strongDelegate.intervalMin = 15;
                break;
            default:
                strongDelegate.intervalMin = 5;
                break;
            }
        }
        standardUserDefaults.setInteger(sender.selectedSegmentIndex, forKey: SettingsConstants.IntervalMinKey);
        standardUserDefaults.synchronize();
    }
    
    
    @IBAction func includeInaccurateChanged(sender: UISwitch) {
        if let strongDelegate = delegate {
            strongDelegate.includeInaccurateResults = sender.on;
        }
        standardUserDefaults.setBool(sender.on, forKey: SettingsConstants.IncludeInaccurateResultsKey);
        standardUserDefaults.synchronize();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if(standardUserDefaults.objectForKey(SettingsConstants.IncludeInaccurateResultsKey) == nil){
            standardUserDefaults.setBool(true, forKey: SettingsConstants.IncludeInaccurateResultsKey);
        }
        if(standardUserDefaults.objectForKey(SettingsConstants.RadiusKey) == nil){
            standardUserDefaults.setInteger(1, forKey: SettingsConstants.RadiusKey);
        }
        if(standardUserDefaults.objectForKey(SettingsConstants.HoursUntilStaleKey) == nil){
            standardUserDefaults.setInteger(1, forKey: SettingsConstants.HoursUntilStaleKey);
        }
        if(standardUserDefaults.objectForKey(SettingsConstants.IntervalMinKey) == nil){
            standardUserDefaults.setInteger(0, forKey: SettingsConstants.IntervalMinKey);
        }
        standardUserDefaults.synchronize();
        
        includeInaccurateResultsToggle.on = standardUserDefaults.valueForKey(SettingsConstants.IncludeInaccurateResultsKey) as! Bool;
        includeInaccurateChanged(includeInaccurateResultsToggle);
        
        radiusSelector.selectedSegmentIndex = standardUserDefaults.valueForKey(SettingsConstants.RadiusKey) as! Int;
        radiusChanged(radiusSelector);
        
        lookbackSelector.selectedSegmentIndex = standardUserDefaults.valueForKey(SettingsConstants.HoursUntilStaleKey) as! Int;
        lookbackChanged(lookbackSelector);
        
        intervalSelector.selectedSegmentIndex = standardUserDefaults.valueForKey(SettingsConstants.IntervalMinKey) as! Int;
        intervalChanged(intervalSelector);
    }
}

protocol QuickSettingsViewControllerDelegate : class {
    var includeInaccurateResults: Bool { get set }
    
    var radius: Int { get set }
    
    var hoursUntilStale: Int { get set }
    
    var intervalMin: Int { get set }
    
    func settingsButtonPressed();
    
    func settingsDismissed();
}