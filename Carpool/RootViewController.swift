//
//  RootViewController.swift
//  Carpool
//
//  Created by Akash Shah and Shannon Zaller on 11/6/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit
import CoreLocation

class RootViewController: UITableViewController {
    
    var trips: [Trip] = []
    var events: [Event] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        API.fetchTripsOnce { (givenTrips) in
            self.trips = givenTrips
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventList", for: indexPath)
        
        //this is not working yet to turn it red.
        if cell.isSelected == true {
            cell.backgroundColor = UIColor.red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

