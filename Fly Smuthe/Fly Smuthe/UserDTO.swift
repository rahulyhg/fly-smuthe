//
//  UserDTO.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 9/7/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class UserDTO : Serializable {
    
    init(email: String){
        Email = email;
    }
    
    var Email: String!
}