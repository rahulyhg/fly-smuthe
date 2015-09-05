//
//  TurbulenceStatisticModel.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/29/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import CoreLocation

class TurbulenceStatisticModel {
    
    init(xAccel: Double!, yAccel: Double!, zAccel: Double!, altitude: Int!, latitude: Double!, longitude: Double!){
        XAccel = xAccel;
        YAccel = yAccel;
        ZAccel = zAccel;
        Latitude = latitude;
        Longitude = longitude;
        self.setAltitude(altitude);
    }
    
    var XAccel: Double!;
    
    var YAccel: Double!;
    
    var ZAccel: Double!;
    
    var Altitude: Int!;
    
    var Latitude: Double!;
    
    var Longitude: Double!;
    
    private func setAltitude(altitude: Int!){
        if(altitude != nil){
            Altitude = Int(round(Double(altitude) / 100.0) * 100);
        }
    }
    
    func hasNotableChange(turbulenceDataState: TurbulenceStatisticModel) -> Bool {
        if(hasNil(turbulenceDataState)){
            return false;
        }
        
        if(hasNil(self)){
            return true;
        }
        
        var thisLocation = CLLocation(latitude: Latitude, longitude: Longitude);
        var newLocation = CLLocation(latitude: turbulenceDataState.Latitude, longitude: turbulenceDataState.Longitude);
        var distanceInMeters = newLocation.distanceFromLocation(thisLocation);
        
        if((distanceInMeters * ConfigurationConstants.NauticalMilesPerMeter) > 0.10){
            return true;
        }
        
        if(Altitude != nil && turbulenceDataState.Altitude != nil && abs(Altitude - turbulenceDataState.Altitude) > 100){
            return true;
        }
        
        if(XAccel != nil && turbulenceDataState.XAccel != nil && fabs(XAccel - turbulenceDataState.XAccel) > 0.05){
            return true;
        }
        
        if(YAccel != nil && turbulenceDataState.YAccel != nil && fabs(YAccel - turbulenceDataState.YAccel) > 0.05){
            return true;
        }
        
        if(ZAccel != nil && turbulenceDataState.ZAccel != nil && fabs(ZAccel - turbulenceDataState.ZAccel) > 0.05){
            return true;
        }
        
        return false;
    }
    
    func hasNil(model: TurbulenceStatisticModel) -> Bool {
        return
            model.XAccel == nil ||
            model.YAccel == nil ||
            model.ZAccel == nil ||
            model.Altitude == nil ||
            model.Latitude == nil ||
            model.Longitude == nil;
    }
}