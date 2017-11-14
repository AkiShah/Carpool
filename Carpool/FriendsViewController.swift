//
//  FriendsViewController.swift
//  Carpool
//
//  Created by Zaller on 11/10/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit
import ContactsUI

class FriendsViewController: UITableViewController, CNContactPickerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let friends = ["Max", "Nathan", "Akash", "Shannon", "Aleshia"]
    var resultSearchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let searchFriendsViewController = storyboard!.instantiateViewController(withIdentifier: "SearchFriendsViewController") as! SearchFriendsViewController
        resultSearchController = UISearchController(searchResultsController: searchFriendsViewController)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.definesPresentationContext = false
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Find New Friends"
        navigationItem.titleView = resultSearchController.searchBar
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let friend = friends[indexPath.row]
        //ability to remove friends
    }
}

extension FriendsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //guard let query = resultSearchController.searchBar.text else { return }
        //let filtered = friends.filter{ $0.contains(query) }
        let vc = resultSearchController.searchResultsController as! SearchFriendsViewController
        //vc.searchResults = filtered
        vc.tableView.reloadData()
    }
}
