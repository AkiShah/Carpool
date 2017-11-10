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
    var resultSearchController:UISearchController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendsSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchFriendsViewController") as! SearchFriendsViewController
        resultSearchController = UISearchController(searchResultsController: friendsSearchTable)
        resultSearchController?.searchResultsUpdater = friendsSearchTable
        
        searchBar.sizeToFit()
        searchBar.placeholder = "Find New Friends"
        navigationItem.titleView = resultSearchController?.searchBar
        
    }
    
}

extension FriendsViewController: UISearchBarDelegate {
    
}

extension FriendsViewController: UISearchControllerDelegate {

}
