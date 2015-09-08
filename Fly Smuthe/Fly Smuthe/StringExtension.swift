//
//  StringExtension.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/4/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

extension String {
    func sub(this: String, with: String) -> String {
        return self.stringByReplacingOccurrencesOfString(this, withString: with);
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx);
        return emailTest.evaluateWithObject(self);
    }
}
