//
//  SearchFriendsViewController.swift
//  Carpool
//
//  Created by Zaller on 11/10/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class SearchFriendsViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        cell.textLabel?.text = "I WANA BE YOUR FUEND"
        //WILL YOU BE MY FUEND??
        return cell
    }
    
}

extension SearchFriendsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
    
}
