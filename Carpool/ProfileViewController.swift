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
    @IBOutlet weak var childTableView: UITableView!
    
    //var user: User?
    var children: [Child] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        updateChildrenTableView()
        childTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childList", for: indexPath)
            cell.textLabel?.text = children[indexPath.row].name
        cell.layer.cornerRadius = 30
        cell.layer.borderColor = UIColor.init(displayP3Red: 1.0, green: 0.99, blue: 0.91, alpha: 1.0).cgColor
        cell.layer.borderWidth = 10
        
        cell.textLabel?.text = children[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        API.ruthlesslyKillChildWithoutRemorseOrMoralCompassLikeDudeWhatKindOfPersonAreYouQuestionMark(children[indexPath.row])
        children.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
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
