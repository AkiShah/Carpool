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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        API.fetchTripsOnce { (givenTrips) in
            self.trips = givenTrips
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let trip = sender as? Trip else { return }
            let eventDetailVC = segue.destination as! EventDetailViewController
            eventDetailVC.trip = trip
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventList", for: indexPath)
        
        let trip = trips[indexPath.row]
        cell.textLabel?.text = trip.event.description
        print("Pickup?:\(trip.pickUp.isClaimed) Dropoff?:\(trip.dropOff.isClaimed)")
        if !trip.dropOff.isClaimed || !trip.pickUp.isClaimed {
            cell.backgroundColor = UIColor.red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let trip = trips[indexPath.row]
        if !trip.dropOff.isClaimed || !trip.pickUp.isClaimed {
            let alert = UIAlertController(title: "Claim this Trip", message: "Would you like to claim this pickup/dropoff?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Claim", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "segueToEventDetailVC", sender: trip)
//            let alert = UIAlertController(title: "Unclaim this Trip", message: "Would you like to UNclaim this pickup/dropoff?", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Unclaim", style: .default, handler: nil))
//            alert.addAction(UIAlertAction(title: "Keep this trip", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
        }
    }
}

