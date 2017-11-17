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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.init(displayP3Red: 0.91, green: 0.76, blue: 0.51, alpha: 1)
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
        cell.textLabel?.text = searchResults[indexPath.row].name
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
            case .success(let users):
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
