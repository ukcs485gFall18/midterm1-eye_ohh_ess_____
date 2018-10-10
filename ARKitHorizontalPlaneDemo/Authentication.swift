//
//  Authentication.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 9/29/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import Foundation
import FirebaseAuth

class Authentication {
    private static let instance = Authentication()
    static var sharedInstance: Authentication {
        return instance
    }
    private init() {}
    
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    

}
