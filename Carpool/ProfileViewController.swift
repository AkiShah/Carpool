//
//  ProfileViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class ProfileViewController: UIViewController, UITableViewDataSource {
    
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
    var children: [Child] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.fetchCurrentUser { result in
            switch result {
                
            case .success(let user):
                self.user = user
                self.children = user.children
                self.userNameLabel.text = user.name
                self.childTableView.reloadData()
            case .failure(_):
                break//todo error
                
            }
        }
        //populating the data of which children are the user's
        childTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.children.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childList", for: indexPath)
        cell.textLabel?.text = user?.children[indexPath.row].name
        print(children)
        return cell
    }
    
    @IBAction func onEditProfilePressed(_ sender: UIButton) {
        userNameEdited.isHidden = false
        partnerNameEdited.isHidden = false
        childNameAdded.isHidden = false
        partnerNameLabel.isHidden = false
        partnerNameEdited.isHidden = false
        editProfileButton.titleLabel?.text = "Confirm Changes?"
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
                    self.childTableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}
