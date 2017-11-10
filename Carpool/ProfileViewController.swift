//
//  ProfileViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit
import FirebaseCommunity

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: logMeInNotificationName, object: nil, queue: .main) { _ in
            if let loginVC = self.presentedViewController as? LoginViewController {
                loginVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            print(currentUser)
            NotificationCenter.default.post(name: logMeInNotificationName, object: nil)
        } else {
            let loginVC = storyboard!.instantiateViewController(withIdentifier: "LoginVC")
            present(loginVC, animated: animated, completion: nil)
        }
    }

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBAction func onEditProfilePressed(_ sender: UIButton) {
    }
    @IBOutlet weak var onUserNameEdited: UITextField!
    @IBOutlet weak var onPartnerNameEdited: UITextField!
    @IBOutlet weak var onChildNameAdded: UITextField!
    @IBOutlet weak var onSignOutPressed: UIButton!
    @IBOutlet weak var childTableView: UITableView!
    
}
