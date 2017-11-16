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
                self.tableView.reloadData()
            case .failure(let error):
                let alert = UIAlertController(title: "One is the loneliest number.", message: "I'm sure you have friends, but I don't see them here \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Thanks, I'll add friends", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
        cell.detailTextLabel?.text = getChildStrings(for: friends[indexPath.row])
        
        cell.layer.cornerRadius = 20
        cell.layer.borderColor = UIColor.init(displayP3Red: 1.0, green: 0.99, blue: 0.91, alpha: 1.0).cgColor
        cell.layer.borderWidth = 10

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "MY FRIENDS"
    }
    
    func getChildStrings(for friend: User) -> String {
        if friend.children.count > 0 {
            let childrenNames = friend.children.map({$0.name}).sorted(by: {$0 < $1})
            var childString = childrenNames.joined(separator: ", ")
            
            if let lastCommaRange = childString.range(of: ", ", options: .backwards) {
                childString.replaceSubrange(lastCommaRange, with: " and ")
            }
            return childString
        }
        return ""
    }
    
}
