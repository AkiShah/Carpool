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

class FriendsViewController: UIViewController, CNContactPickerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "What's that parent's name again?"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
}

extension FriendsViewController: UISearchBarDelegate {
    
}

extension FriendsViewController: UISearchControllerDelegate {

}

extension FriendsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    

}
