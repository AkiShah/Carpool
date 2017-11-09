//
//  LoginViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import FirebaseCommunity

let logMeInNotificationName = Notification.Name("LogMeInDidCompleteNotification")

class LoginViewController: UIViewController {
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordConfirmButton: UITextField!
    
    var userEmail: String = ""
    var userPassword: String = ""
    var userPasswordConfirm: String = ""
    
    enum ToggleState: Int {
        case login
        case signup
        
        var isHidden: Bool {
            switch self {
            case .login:
                return true
            case .signup:
                return false
            }
        }
        
        var text: String {
            switch self {
            case .login:
                return "Login"
            case .signup:
                return "Signup"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        toggleLabels(to: ToggleState(rawValue: sender.selectedSegmentIndex)!)
    }
    
    func toggleLabels(to state: ToggleState) {
        loginButton.setTitle(state.text, for: .normal)
        passwordConfirmButton.isHidden = state.isHidden
    }
    
    @IBAction func onLoginPressed(_ sender: UIButton) {
        
        switch ToggleState(rawValue: segmentedController.selectedSegmentIndex)! {
        case .login:
            if userEmail != "", userPassword != "" {
                Auth.auth().signIn(withEmail: userEmail, password: userPassword, completion: { user, error in
                    if let user = user {
                        //Sign in Worked
                        print("Signin Worked, \(user)")
                    } else if let error = error {
                        //Signin Didn't work
                        print(#function, error)
                    }
                })
            }
        case .signup:
            if userEmail != "", userPassword != "", userPassword == userPasswordConfirm {
                Auth.auth().createUser(withEmail: userEmail, password: userPassword, completion: { user, error in
                    if let user = user {
                        //Signup Worked
                        print("User Created, \(user)")
                    } else if let error = error {
                        //Signup Failed
                        print(#function, error)
                    }
                })
            }
        }
    }
    
    @IBAction func onEmailEntered(_ sender: UITextField) {
        if let text = sender.text {
            userEmail = text
        }
    }
    
    @IBAction func onPasswordEntered(_ sender: UITextField) {
        if let text = sender.text {
            userPassword = text
        }
    }
    
    @IBAction func onPasswordConfirmedEntered(_ sender: UITextField) {
        if let text = sender.text {
            userPasswordConfirm = text
        }
    }
}
