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

class FriendsViewController: UITableViewController, CNContactPickerDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var resultSearchController:UISearchController? = nil
    //let friends: [User] = []
    let friends = ["Max", "Nathan", "Akash", "Shannon", "Aleshia"]
    
    
    //this is me trying to get the filtered search function to work with friends, but the friends are not populating. I've hard coded them above for testing. The old code is at the bottom, commented out if this is bad. But we would have to still fix the double search bar issue. 
    
    var searchActive : Bool = false
    var filtered:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = friends.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return friends.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! UITableViewCell;
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = friends[indexPath.row];
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
    }
    
    
}

// Need to fix the double search bar
//
//        let friendsSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchFriendsViewController") as! SearchFriendsViewController
//        resultSearchController = UISearchController(searchResultsController: friendsSearchTable)
//        resultSearchController?.searchResultsUpdater = friendsSearchTable
//
//
//
//        searchBar.sizeToFit()
//        searchBar.placeholder = "Find New Friends"
//        navigationItem.titleView = resultSearchController?.searchBar
//
//    }
//
//}
//
//extension FriendsViewController: UISearchBarDelegate {
//
//}
//
//extension FriendsViewController: UISearchControllerDelegate {
//
//}

