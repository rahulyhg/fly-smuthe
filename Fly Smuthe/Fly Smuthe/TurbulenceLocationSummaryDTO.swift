//
//  TurbulenceLocationSummaryDTO.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/5/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class TurbulenceLocationSummaryDTO {
    init(altitude: Int, averageIntensity: Double, bumps: Int, bumpsPerMinute: Double, description: String, minutes: Double, intensityRating: Int){
        Altitude = altitude;
        AverageIntensity = averageIntensity;
        Bumps = bumps;
        BumpsPerMinute = bumpsPerMinute;
        Description = description;
        Minutes = minutes;
        IntensityRating = intensityRating;
    }
    
    var Altitude: Int!;
    
    var AverageIntensity: Double!;
    
    var Bumps: Int!;
    
    var BumpsPerMinute: Double!;
    
    var Description: String!;
    
    var IntensityRating: Int!;
    
    var Minutes: Double!;
}