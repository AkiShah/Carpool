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
    @IBOutlet weak var childNameAdded: UITextField!
    @IBOutlet weak var onSignOutPressed: UIButton!
    @IBOutlet weak var childTableView: UITableView!
    
    var user: User?
    var children: [Child] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateChildrenTableView()
        
        //populating the data of which children are the user's
        childTableView.dataSource = self
        
        
        if editProfileButton.isSelected == true {
            userNameEdited.isHidden = false
            partnerNameEdited.isHidden = false
            childNameAdded.isHidden = false
            partnerNameLabel.isHidden = false
            partnerNameEdited.isHidden = false
            editProfileButton.isSelected = true
        } else {
            userNameEdited.isHidden = true
            partnerNameEdited.isHidden = true
            childNameAdded.isHidden = true
            partnerNameLabel.isHidden = true
            partnerNameEdited.isHidden = true
            editProfileButton.isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childList", for: indexPath)
        cell.textLabel?.text = user?.children[indexPath.row].name
        print(children)
        return cell
    }
    
<<<<<<< HEAD
    @IBAction func onEditProfilePressed(_ sender: UIButton) {
        userNameEdited.isHidden = false
        partnerNameEdited.isHidden = false
        childNameAdded.isHidden = false
        partnerNameLabel.isHidden = false
        partnerNameEdited.isHidden = false
        editProfileButton.isSelected = true
    }
    
    @IBAction func onUserNameEdited(_ sender: UITextField) {
        if let name = sender.text {
            userNameLabel.text = name
        }
    }
    @IBAction func onPartnerNameEdited(_ sender: UITextField) {
        if let myFatedSoulMate = sender.text {
            // Function to set your partner
            partnerNameLabel.text = myFatedSoulMate
        }
    }
=======
>>>>>>> master
    @IBAction func onChildNameAdded(_ sender: UITextField) {
        if let theMistake = sender.text {
            API.addChild(name: theMistake, completion: { result in
                switch result {
                case .success(_):
                    self.updateChildrenTableView()
                case .failure(let error):
                    let alert = UIAlertController(title: "Whoops", message: "Wasn't able to add a new child. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print(error)
                }
            })
        }
    }
    
    func updateChildrenTableView() {
        API.fetchCurrentUser { result in
            switch result {
            case .success(let user):
                self.user = user
                self.children = user.children
                self.userNameLabel.text = user.name
                self.childTableView.reloadData()
            case .failure(let error):
                let alert = UIAlertController(title: "Whoops", message: "Couldn't get user info. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
