//
//  RegistrationViewController.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/7/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import UIKit

class RegistrationViewController : UIViewController {
    
    let apiWebProxy = APIWebProxy();
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func continueButtonClicked(sender: UIButton) {
        activityIndicator.startAnimating();
        continueButton.hidden = true;
        
        if(!emailTextField.text.isValidEmail()){
            self.activityIndicator.stopAnimating();
            self.continueButton.hidden = false;
            
            errorLabel.text = "please enter a valid email address";
            errorLabel.hidden = false;
            errorLabel.alpha = 1.0;
            UIView.animateWithDuration(2.5, animations: {
                self.errorLabel.alpha = 0.0
            });
            
            return;
        }
        
        let userDTO = UserDTO(email: emailTextField.text);
        
        // Post to web api
        self.apiWebProxy.post(userDTO, credential: "", url: APIURLConstants.Register, expectsEncryptedResponse: false, postCompleted: { (succeeded: Bool, msg: String, json: NSDictionary?) -> () in
            
            // If unsuccessful, the data will remain local and keep trying
            // to sync until it is stale
            var parsed = false;
            if(succeeded) {
                if let parseJSON = json {
                    if let responseCode = parseJSON["ResponseCode"]?.integerValue {
                        // If successful, delete the local row
                        if(responseCode == ResponseCodes.Success){
                            DeviceConfigurationManager.sharedInstance.saveAccessId(parseJSON["APIId"]! as! String);
                            DeviceConfigurationManager.sharedInstance.saveAccessKey(parseJSON["APIKey"]! as! String);
                            
                            ThreadUtility.runOnMainThread(){
                                self.performSegueWithIdentifier("registrationCompleteSegue", sender: self);
                            };
                        }
                    }
                    
                }
            }
            
            ThreadUtility.runOnMainThread(){
                self.activityIndicator.stopAnimating();
                self.continueButton.hidden = false;
            }
        });
    }
}