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
    @IBOutlet weak var userNameEdited: UITextField!
    @IBOutlet weak var partnerNameEdited: UITextField!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var childNameAdded: UITextField!
    @IBOutlet weak var partnerHeader: UILabel!
    @IBOutlet weak var onSignOutPressed: UIButton!
    @IBOutlet weak var childTableView: UITableView!
    
    var user: User?
    //Pull the kids names for table from here
    var children: [Child] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.fetchCurrentUser { result in
            switch result {
                
            case .success(let user):
                self.user = user
                self.userNameLabel.text = user.name
                self.children = user.children
            case .failure(_):
                break//todo error
                
            }
        }
        
        if partnerNameLabel.text == "" {
            partnerNameLabel.isHidden = true
            partnerHeader.isHidden = true
        } else {
            partnerNameLabel.isHidden = false
            partnerHeader.isHidden = false
        }
    }
    
    @IBAction func onEditProfilePressed(_ sender: UIButton) {
        userNameEdited.isHidden = false
        partnerNameEdited.isHidden = false
        childNameAdded.isHidden = false
        partnerNameLabel.isHidden = false
        partnerNameEdited.isHidden = false
    }
    
    @IBAction func onUserNameEdited(_ sender: UITextField) {
        if let name = sender.text {
            API.set(userFullName: name)
            userNameLabel.text = name
        }
        
    }
    @IBAction func onPartnerNameEdited(_ sender: UITextField) {
        if let myFatedSoulMate = sender.text {
            // Function to set your partner
            partnerNameLabel.text = myFatedSoulMate
        }
    }
    @IBAction func onChildNameAdded(_ sender: UITextField) {
        if let theMistake = sender.text {
            API.addChild(name: theMistake, completion: { result in
                switch result {
                case .success(let child):
                    self.children.append(child)
                case .failure(let error):
                    //TODO ERROR HANDLING
                    print(error)
                }
            })
        }
    }
}
