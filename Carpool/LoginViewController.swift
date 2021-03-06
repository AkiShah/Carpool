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
    
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var onNameEntered: UITextField!
    @IBOutlet weak var passwordConfirmButton: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
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
                return "LOGIN"
            case .signup:
                return "SIGN UP"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        nameTextField.backgroundColor = UIColor.init(red: 0.29, green: 0.31, blue: 0.40, alpha: 1.0)
//        onNameEntered.backgroundColor = UIColor.init(red: 0.29, green: 0.31, blue: 0.40, alpha: 1.0)
//        passwordConfirmButton.backgroundColor = UIColor.init(red: 0.29, green: 0.31, blue: 0.40, alpha: 1.0)
//
//        nameTextField.attributedPlaceholder = NSAttributedString(string:"Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(displayP3Red: 0.91, green: 0.76, blue: 0.51, alpha: 1.0)])
//        emailLabel.attributedPlaceholder = NSAttributedString(string:"Email Address", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(displayP3Red: 0.91, green: 0.76, blue: 0.51, alpha: 1.0)])
//        passwordLabel.attributedPlaceholder = NSAttributedString(string:"Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(displayP3Red: 0.91, green: 0.76, blue: 0.51, alpha: 1.0)])
//        passwordConfirmButton.attributedPlaceholder = NSAttributedString(string:"Confirm Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(displayP3Red: 0.91, green: 0.76, blue: 0.51, alpha: 1.0)])
//
    }
    
    @IBAction func onSkipPressed(_ sender: UIButton) {
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        let currentState = ToggleState(rawValue: sender.selectedSegmentIndex)!
        toggleLabels(to: currentState)

    
    }
    
    func toggleLabels(to state: ToggleState) {
        loginButton.setTitle(state.text, for: .normal)
        passwordConfirmButton.isHidden = state.isHidden
        confirmPasswordLabel.isHidden = state.isHidden
        nameTextField.isHidden = state.isHidden
        nameLabel.isHidden = state.isHidden

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
                    }
                })
            }
        }
    }
    
    
    @IBAction func onEmailEntered(_ sender: UITextField) {
        if let text = sender.text {
            userEmail = text
        }
        
        print(#function, "it ended on exit")
    }
    
//    @IBAction func onEmailEntered(_ sender: UITextField) {
//        if let text = sender.text {
//            userEmail = text
//        }
//    }
    
    @IBAction func onPasswordEntered(_ sender: UITextField) {
        if let text = sender.text {
            userPassword = text
        }
    }
    
    
//    @IBAction func onPasswordEntered(_ sender: UITextField) {
//        if let text = sender.text {
//            userPassword = text
//        }
//    }
    
    @IBAction func onNameEntered(_ sender: UITextField) {
        if let name = sender.text {
            userName = name
        }
    }
    
    
//    @IBAction func onNameEntered(_ sender: UITextField) {
//        if let name  = sender.text {
//            userName = name
//        }
//
//    }
    
    @IBAction func onPasswordConfirmedEntered(_ sender: UITextField) {
        if let text = sender.text {
            userPasswordConfirm = text
        }
    }
    
    
    
//    @IBAction func onPasswordConfirmedEntered(_ sender: UITextField) {
//        if let text = sender.text {
//            userPasswordConfirm = text
//        }
//    }
}
