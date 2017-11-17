//
//  SearchFriendsViewController.swift
//  Carpool
//
//  Created by Zaller on 11/10/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit
import MessageUI

class SearchFriendsViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchQuery = ""
    var searchResults: [User] = []
    var friends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.init(displayP3Red: 0.91, green: 0.76, blue: 0.51, alpha: 1)
        
        API.observeFriends(sender: self) { (result) in
            switch result {
                
            case .success(let friends):
                self.friends = friends
            case .failure(let error):
                print(#function, error)
            }
        }
    }
    
    @IBAction func onSendTextPressed(_ sender: UIButton) {
        let messageComposer = MessageComposer()
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            // Present the configured MFMessageComposeViewController instance
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let alert = UIAlertController(title: "That didn't work.", message: "Your device is not able to send text messages.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.text = searchResults[indexPath.row].name
        cell.detailTextLabel?.text = searchResults[indexPath.row].childrenAsString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        API.add(friend: searchResults[indexPath.row])
    }
}

extension SearchFriendsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //Do something the first time the user first stated editing search bar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        API.search(forUsersWithName: searchText) { result in
            switch result {
            case .success(var users):
                for friend in self.friends {
                    if let index = users.index(of: friend) {
                        users.remove(at: index)
                    }
                }
                for user in users {
                    if user.isMe {
                        users.remove(at: users.index(of: user)!)
                    }
                }
                self.searchResults = users
                self.tableView.reloadData()
                
            case .failure(let error):
                let alert = UIAlertController(title: "New phone, who dis?", message: "Database Error. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "It's not your fault", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print(#function, error)
            }
        }
    }
}

extension User {
    var childrenAsString: String {
        if children.count > 0 {
            let childrenNames = children.map({$0.name}).sorted(by: {$0 < $1})
            var childString = childrenNames.joined(separator: ", ")
            
            if let lastCommaRange = childString.range(of: ", ", options: .backwards) {
                childString.replaceSubrange(lastCommaRange, with: " and ")
            }
            return childString
        } else {
            return ""
        }
    }
}
