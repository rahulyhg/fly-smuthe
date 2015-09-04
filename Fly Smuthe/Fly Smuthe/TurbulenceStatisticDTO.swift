//
//  TurbulenceStatisticDTO.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/30/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class TurbulenceStatisticDTO : Serializable {
    init(xAccel: Double, yAccel: Double, zAccel: Double, altitude: Int, latitude: Double, longitude: Double, created: NSDate, groupId: String){
        XAccel = String(format:"%f",xAccel);
        YAccel = String(format:"%f",yAccel);
        ZAccel = String(format:"%f",zAccel);
        Altitude = String(altitude);
        Latitude = String(format:"%f",latitude);
        Longitude = String(format:"%f",longitude);
        
        let dateFormatter = NSDateFormatter();
        let timeZone = NSTimeZone(name: "UTC");
        dateFormatter.timeZone = timeZone;
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX";
        self.Created = dateFormatter.stringFromDate(created);
        
        self.GroupId = groupId;
    }
    
    var XAccel: String!;
    
    var YAccel: String!;
    
    var ZAccel: String!;
    
    var Altitude: String!;
    
    var Latitude: String!;
    
    var Longitude: String!;
    
    var Created: String!;
    
    var GroupId: String!;
}