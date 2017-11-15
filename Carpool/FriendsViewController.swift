//
//  FriendsViewController.swift
//  Carpool
//
//  Created by Zaller on 11/10/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class FriendsViewController: UITableViewController{
    

    var friends: [User] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        API.observeFriends(sender: self) { result in
            switch result {
            case .success(let users):
                self.friends = users
                print(users)
                self.tableView.reloadData()
            case .failure(let error):
                print(#function, error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].name
        //Write the children names in subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
