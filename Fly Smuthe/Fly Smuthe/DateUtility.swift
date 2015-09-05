//
//  DateUtility.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 3/22/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class DateUtility {
    class func toUTCDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter();
        let timeZone = NSTimeZone(name: "CDT");
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        dateFormatter.timeZone = timeZone;
        let date = dateFormatter.dateFromString(dateString);
        
        return date!;
    }
    
    class func toLocalDateString(date: NSDate!) -> String {
        if(date == nil){
            return "";
        }
        let dateFormatter = NSDateFormatter();
        let timeZone = NSTimeZone.defaultTimeZone();
        dateFormatter.timeZone = timeZone;
        dateFormatter.dateFormat = "MMM d, h:mma";
        return dateFormatter.stringFromDate(date);
    }
    
    class func toServerDateString(date: NSDate!) -> String {
        if(date == nil){
            return "";
        }
        let dateFormatter = NSDateFormatter();
        let timeZone = NSTimeZone(name: "CDT");
        dateFormatter.timeZone = timeZone;
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        return dateFormatter.stringFromDate(date);
    }
}

extension NSDate: Comparable {
    
}

func + (date: NSDate, timeInterval: NSTimeInterval) -> NSDate {
    return date.dateByAddingTimeInterval(timeInterval)
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs) == .OrderedSame {
        return true
    }
    return false
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs) == .OrderedAscending {
        return true
    }
    return false
}

extension NSTimeInterval {
    var withMinutes: NSTimeInterval {
        let secondsInAMinute = 60 as NSTimeInterval
        return self * secondsInAMinute;
    }
    
    var second: NSTimeInterval {
        return self.seconds
    }
    
    var seconds: NSTimeInterval {
        return self
    }
    
    var minute: NSTimeInterval {
        return self.minutes
    }
    
    var minutes: NSTimeInterval {
        let secondsInAMinute = 60 as NSTimeInterval
        return self / secondsInAMinute
    }
    
    var hours: NSTimeInterval {
        let secondsInAMinute = 60 as NSTimeInterval
        let minutesInAnHour = 60 as NSTimeInterval
        return self / secondsInAMinute / minutesInAnHour
    }
    
    var day: NSTimeInterval {
        return self.days
    }
    
    var days: NSTimeInterval {
        let secondsInADay = 86_400 as NSTimeInterval
        return self / secondsInADay
    }
    
    var fromNowFriendlyString: String {
        var returnStr = "";
        if(self > 0){
            if(self.days >= 1){
                returnStr = String(Int(floor(self.days))) + " day";
            } else if (self.hours >= 1){
                let hours = Int(floor(self.hours));
                returnStr = String(hours) + " hour" + (hours > 1 ? "s" : "");
            } else if (self.minutes >= 1){
                let minutes = Int(floor(self.minutes));
                returnStr = String(minutes) + " minute" + (minutes > 1 ? "s" : "");
            } else if (self >= 1){
                let seconds = Int(self);
                returnStr = String(seconds) + " second" + (seconds > 1 ? "s" : "");
            }
        }
        return returnStr;
    }
    
    var timerString: String {
        let interval = Int(self);
        let seconds = interval % 60;
        let minutes = (interval / 60) % 60;
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var fromNow: NSDate {
        let timeInterval = self
        return NSDate().dateByAddingTimeInterval(timeInterval)
    }
    
    func from(date: NSDate) -> NSDate {
        let timeInterval = self
        return date.dateByAddingTimeInterval(timeInterval)
    }
    
    var ago: NSDate {
        let timeInterval = self
        return NSDate().dateByAddingTimeInterval(-timeInterval)
    }
}