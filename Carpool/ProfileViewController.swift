//
//  ProfileViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var onUserNameEdited: UITextField!
    @IBOutlet weak var onPartnerNameEdited: UITextField!
    @IBOutlet weak var onChildNameAdded: UITextField!
    @IBOutlet weak var onSignOutPressed: UIButton!
    @IBOutlet weak var childTableView: UITableView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        API.fetchCurrentUser { result in
            switch result {
                
            case .success(let user):
                self.user = user
                self.userNameLabel.text = user.name
            case .failure(_):
                break//todo error
            }
        }
        
        onUserNameEdited.isHidden = true
        onPartnerNameEdited.isHidden = true
        
    }
    
    @IBAction func onEditProfilePressed(_ sender: UIButton) {
    }
}
