//
//  LoginViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

let loginNotification = Notification.Name("login Did Complete Notification")

class LoginViewController: UIViewController {
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var onNameEntered: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordConfirmButton: UITextField!
    
    var userEmail: String = ""
    var userPassword: String = ""
    var userPasswordConfirm: String = ""
    var userName: String = ""
    
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
    
    @IBAction func onSkipPressed(_ sender: UIButton) {
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        toggleLabels(to: ToggleState(rawValue: sender.selectedSegmentIndex)!)
    }
    
    func toggleLabels(to state: ToggleState) {
        loginButton.setTitle(state.text, for: .normal)
        passwordConfirmButton.isHidden = state.isHidden
        nameTextField.isHidden = state.isHidden
    }
    
    
    @IBAction func onLoginPressed(_ sender: UIButton) {
        
        switch ToggleState(rawValue: segmentedController.selectedSegmentIndex)! {
        case .login:
            print("userEmail: \(userEmail), userPassword: \(userPassword)")
            if userEmail != "", userPassword != "" {
                API.signIn(email: userEmail, password: userPassword, completion: { result in
                    switch result {
                    case .success(let user):
                        print(user)
                        NotificationCenter.default.post(name: loginNotification, object: nil)
                    case .failure(let error):
                        let alert = UIAlertController(title: "Whoops", message: "Your email or password was invalid. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print(error)
                        let alert = UIAlertController(title: "Whoops", message: "Login didn't work. Check your login info or sign up for an account.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "I'll try again!", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        case .signup:
            print("userName: \(userName), userEmail: \(userEmail), userPassword: \(userPassword), userPasswordConfirmed: \(userPasswordConfirm)")
            if userEmail != "", userPassword != "", userPassword == userPasswordConfirm, userName != "" {
                API.signUp(email: userEmail, password: userPassword, fullName: userName, completion: { result in
                    switch result {
                    case .success(let user):
                        print(user)
                        NotificationCenter.default.post(name: loginNotification, object: nil)
                    case .failure(let error):
                        let alert = UIAlertController(title: "Whoops", message: "Your email or password was not accepted. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print(error)
                        let alert = UIAlertController(title: "Whoops", message: "Signup didn't work. Check your passwords again. If you've already created an account, click Login and try again.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "I'll try again!", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func onNameEntered(_ sender: UITextField) {
        if let name  = sender.text {
            userName = name
        }
        
    }
    
    @IBAction func onPasswordConfirmedEntered(_ sender: UITextField) {
        if let text = sender.text {
            userPasswordConfirm = text
        }
    }
}
