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
    
    private let NauticalMilesPerMeter = 0.000539957;
    
    init(xAccel: Double!, yAccel: Double!, zAccel: Double!, altitude: Int!, latitude: Double!, longitude: Double!){
        XAccel = xAccel;
        YAccel = yAccel;
        ZAccel = zAccel;
        Altitude = altitude;
        Latitude = latitude;
        Longitude = longitude;
    }
    
    var XAccel: Double!;
    
    var YAccel: Double!;
    
    var ZAccel: Double!;
    
    var Altitude: Int!;
    
    var Latitude: Double!;
    
    var Longitude: Double!;
    
    func hasNotableChange(turbulenceDataState: TurbulenceStatisticModel) -> Bool {
        if(XAccel == nil && turbulenceDataState.XAccel != nil){
            return true;
        }
        if(YAccel == nil && turbulenceDataState.YAccel != nil){
            return true;
        }
        if(ZAccel == nil && turbulenceDataState.ZAccel != nil){
            return true;
        }
        if(Altitude == nil && turbulenceDataState.Altitude != nil){
            return true;
        }
        if(Latitude == nil && turbulenceDataState.Latitude != nil){
            return true;
        }
        if(Longitude == nil && turbulenceDataState.Longitude != nil){
            return true;
        }
        
        var thisLocation = CLLocation(latitude: Latitude, longitude: Longitude);
        var newLocation = CLLocation(latitude: turbulenceDataState.Latitude, longitude: turbulenceDataState.Longitude);
        var distanceInMeters = newLocation.distanceFromLocation(thisLocation);
        
        if((distanceInMeters * NauticalMilesPerMeter) > 0.10){
            return true;
        }
        
        if(abs(Altitude - turbulenceDataState.Altitude) > 100){
            return true;
        }
        
        return false;
    }
}