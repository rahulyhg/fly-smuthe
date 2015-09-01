//
//  APIWebProxy.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 2/22/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class APIWebProxy {
    
    func post(param : Serializable!, credential: String, url : String, expectsEncryptedResponse: Bool = true, postCompleted : (succeeded: Bool, msg: String, json: NSDictionary?) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        
        var jsonString = "{}" as NSString;
        if(param != nil) {
            jsonString = param!.toJsonString()!;
        }
        
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!;
        request.addValue(String(jsonString.length), forHTTPHeaderField: "Content-Length");
        request.addValue("Basic " + credential, forHTTPHeaderField: "Authorization");
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("100-continue", forHTTPHeaderField: "Expect");
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control");
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            var responseData = data;
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(responseData, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "I couldn't reach the mother ship. Please try again!", json: nil)
            }
            else {
                postCompleted(succeeded: true, msg: "Success", json: json)
            }
        })
        
        task.resume()
    }
}