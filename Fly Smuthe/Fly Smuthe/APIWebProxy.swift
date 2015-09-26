//
//  APIWebProxy.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 2/22/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class APIWebProxy {
    
    func get(credential: String, url: String, getCompleted: (succeeded: Bool, msg: String, json: NSDictionary?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var thisCredential: String;
        if(credential.characters.count == 0){
            thisCredential = SecurityConstants.APIId + ":" + SecurityConstants.APISecret;
        } else {
            thisCredential = credential;
        }
        
        let thisCredentialData = ([UInt8](thisCredential.utf8));
        let thisCredentialBase64 = NSData(bytes: thisCredentialData, length: thisCredentialData.count).base64EncodedStringWithOptions([]);
        
        request.addValue("Basic " + thisCredentialBase64, forHTTPHeaderField: "Authorization");
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("100-continue", forHTTPHeaderField: "Expect");
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control");
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            let responseData = data;
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: .MutableLeaves) as? NSDictionary
                
                getCompleted(succeeded: true, msg: "Success", json: json)
            } catch {
                let jsonStr = NSString(data: responseData!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                getCompleted(succeeded: false, msg: "I couldn't reach the mother ship. Please try again!", json: nil)
            }
        })
        
        task.resume()

    }
    
    func post(param : Serializable!, credential: String, url : String, expectsEncryptedResponse: Bool = true, postCompleted : (succeeded: Bool, msg: String, json: NSDictionary?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var jsonString = "{}" as NSString;
        if(param != nil) {
            jsonString = param!.toJsonString()!;
        }
        
        var thisCredential: String;
        if(credential.characters.count == 0){
            thisCredential = SecurityConstants.APIId + ":" + SecurityConstants.APISecret;
        } else {
            thisCredential = credential;
        }
        
        let thisCredentialData = ([UInt8](thisCredential.utf8));
        let thisCredentialBase64 = NSData(bytes: thisCredentialData, length: thisCredentialData.count).base64EncodedStringWithOptions([]);
        
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!;
        request.addValue(String(jsonString.length), forHTTPHeaderField: "Content-Length");
        request.addValue("Basic " + thisCredentialBase64, forHTTPHeaderField: "Authorization");
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("100-continue", forHTTPHeaderField: "Expect");
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control");
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            let responseData = data;
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: .MutableLeaves) as? NSDictionary
                
                postCompleted(succeeded: true, msg: "Success", json: json)
            } catch {
                let jsonStr = NSString(data: responseData!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "I couldn't reach the mother ship. Please try again!", json: nil)
            }
        })
        
        task.resume()
    }
}