//
//  AuthVC.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 9/29/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import FirebaseUI


class AuthVC: UIViewController, FUIAuthDelegate {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("appeared....")
        view.backgroundColor = .purple
        createFirebaseUI()
    }
    
    private func createFirebaseUI() {
     
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        guard let authVC = authUI?.authViewController() else {return}
        present(authVC, animated: false, completion: nil)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        
        if user {
            return true
        }
        
    }
}
