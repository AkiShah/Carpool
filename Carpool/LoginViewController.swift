//
//  LoginViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import FirebaseCommunity

class LoginViewController: UIViewController {
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var passwordConfirmButton: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
    }
    
    @IBAction func onLoginPressed(_ sender: UIButton) {
    }
    
    @IBAction func onEmailEntered(_ sender: UITextField) {
    }
    
    @IBAction func onPasswordEntered(_ sender: UITextField) {
    }
    
    @IBAction func onPasswordConfirmedEntered(_ sender: UITextField) {
    }
}
