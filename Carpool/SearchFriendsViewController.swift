//
//  SearchFriendsViewController.swift
//  Carpool
//
//  Created by Zaller on 11/10/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class SearchFriendsViewController: UITableViewController, UISearchControllerDelegate {
    
    var searchResults: [String] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResult", for: indexPath)
        cell.textLabel?.text = "I WANA BE YOUR FUEND"
        cell.detailTextLabel?.text = "My Kids are better than yours"
        print("I'm being called")
        cell.backgroundColor = UIColor.cyan
        return cell
    }
}
