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

    override func viewDidLoad() {
        super.viewDidLoad()
        updateChildrenTableView()
        childTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let children = user?.children {
            return children.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childList", for: indexPath)
        if let child = user?.children[indexPath.row].name{
            cell.textLabel?.text = child
        }
        
        return cell
    }
    
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
