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
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
