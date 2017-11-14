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
    
    
    @IBOutlet weak var TripSegmentedViewController: UISegmentedControl!
    
    var downloadedTrips: [Trip] = []
    var trips: [Trip] = []
    var user: User?
    var kids: [Child] = []
    
    enum tripLeg: String {
        case dropoff = " will dropoff"
        case pickup = " will pickup"
    }
    
    enum tripSegment: Int {
        case myTrips
        case friendsTrips
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        API.fetchCurrentUser { result in
            switch result {
                
            case .success(let user):
                self.user = user
                self.trips = self.getTrips(for: tripSegment(rawValue: 0)!)
                self.tableView.reloadData()
                print("User currently is ", user)
            case .failure(let error):
                print("failed to get user")
                print(error)
                let alert = UIAlertController(title: "Whoops", message: "You aren't logged in, but feel free to peruse the app.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Thanks, I think I will", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        API.observeTrips(sender: self) { result in
            switch result {
            case .success(let trips):
                self.downloadedTrips = trips
                if self.user != nil {
                    self.trips = self.getTrips(for: tripSegment(rawValue: self.TripSegmentedViewController.selectedSegmentIndex)!)
                        self.tableView.reloadData()
                }
            case .failure(_):
                //TODO Error Handling
                print("failed to observe trips")
                let alert = UIAlertController(title: "Whoops", message: "There are no upcoming trips. Add a trip or log in to view trips.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Sounds good", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func onTripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if user != nil{
            trips = getTrips(for: tripSegment(rawValue: sender.selectedSegmentIndex)!)
        }
        tableView.reloadData()
    }
    
    func getTrips(for trip: tripSegment) -> [Trip] {
        
        var trips: [Trip] = []
        switch trip {
        case .myTrips:
            trips = downloadedTrips.flatMap({
                let owner = $0.event.owner
                let legDropoff = $0.dropOff?.driver
                let legPickup = $0.pickUp?.driver
                let currentUser = user
                return owner == currentUser || legDropoff == currentUser || legPickup == currentUser ? $0 : nil
            })
        case .friendsTrips:
            trips = downloadedTrips.flatMap({
                let owner = $0.event.owner
                let legDropoff = $0.dropOff?.driver
                let legPickup = $0.pickUp?.driver
                let currentUser = user
                return owner != currentUser && legDropoff != currentUser && legPickup != currentUser ? $0 : nil
            })
        }
        
        return trips
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = trips[indexPath.row]
        let dsc = trip.event.description == "" ? "No description given" : trip.generateSmartDescription
        //let kid = trip.children[indexPath.row]
        cell.descriptionLabel.text = dsc
        //cell.kidNames.text = kid.name

        if dsc == "" {
            cell.descriptionLabel.font = UIFont.italicSystemFont(ofSize: (cell.descriptionLabel.font.pointSize))
        } else {
            cell.descriptionLabel.font = UIFont.boldSystemFont(ofSize: cell.descriptionLabel.font.pointSize)
        }
        
        setProps(cell.dropoffLabel, cell.dropoffCarBlue, for: trip.dropOff, as: .dropoff)
        setProps(cell.pickupLabel, cell.pickupCarPink, for: trip.pickUp, as: .pickup)
        
        return cell
    }
    
    func setProps(_ label: UILabel, _ carImage: UIImageView, for leg: Leg?, as legType: tripLeg) {
        if let leg = leg {
            label.text =  leg.driver.name! + legType.rawValue
            label.textColor = UIColor.black
            label.backgroundColor = UIColor.clear
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
            carImage.alpha = 1.0
        } else {
            label.text = "Not Claimed"
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.red
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
            carImage.alpha = 0.3
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

