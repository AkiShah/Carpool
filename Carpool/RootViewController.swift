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
import FirebaseCommunity

class RootViewController: UITableViewController {
    
    var trips: [Trip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //would like to create a title for header in section splitting out which trips already have both legs claimed, and another section that displays which routes still have an unclaimed leg. That way you don't click on a trip that has both legs already accounted for.
        
        
        API.observeTrips { result in
            
            print(result)
            switch result {
                
            case .success(let trips):
                self.trips = trips
                self.tableView.reloadData()
            case .failure(_):
                //TODO Error Handling
                break
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let trip = sender as? Trip else { return }
            let eventDetailVC = segue.destination as! TripDetailViewController
            eventDetailVC.trip = trip
    }
    
    @IBAction func unwindFromEventDetailViewController(segue: UIStoryboardSegue) {
        self.tableView.reloadData()
    }

    @IBAction func unwindFromCreateTripViewController(segue: UIStoryboardSegue) {
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = trips[indexPath.row]
        
        cell.descriptionLabel.text = trip.event.description
        setProps(cell.dropoffLabel, forTripLeg: trip.dropOff)
        setProps(cell.pickupLabel, forTripLeg: trip.pickUp)
        
        return cell
    }
    
    func setProps(_ label: UILabel, forTripLeg leg: Leg? ) {
        if let leg = leg {
            label.text = leg.driver.name
            label.textColor = UIColor.black
            label.backgroundColor = UIColor.clear
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
        } else {
            label.text = "Not Claimed"
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.red
            label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        self.performSegue(withIdentifier: "segueToEventDetailVC", sender: trip)
    }
}

