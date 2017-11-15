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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchQuery = ""
    var searchResults: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
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
                //TODO error handling
                print(#function, error)
            }
        }
    }
}
