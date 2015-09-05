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
}