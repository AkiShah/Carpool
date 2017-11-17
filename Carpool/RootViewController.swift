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

class RootViewController: UITableViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var TripSegmentedViewController: UISegmentedControl!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    //All Trips
    var myTrips: [Trip] = []
    var myFriendsTrips: [Trip] = []
    //Filtered Trips
    var trips: [Trip] = []
    
    var user: User?
    
    var kids: [Child] = []
    
    var selectedDay = 0
    
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
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        API.observeMyTrips(sender: self) { result in
            switch result {
            case .success(let trips):
                self.myTrips = trips
                self.tableView.reloadData()
            case .failure(let error):
                //TODO error handling
                print(#function, error)
            }
        }
        API.observeTheTripsOfMyFriends(sender: self) { result in
            switch result {
            case .success(let trips):
                self.myFriendsTrips = trips
                print(#function, trips)
                self.tableView.reloadData()
            case .failure(let error):
                //TODO error handling
                print(#function, error)
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let trip = sender as? Trip else { return }
            let eventDetailVC = segue.destination as! AkiTripDetailViewController
            eventDetailVC.trip = trip
    }
    
    @IBAction func unwindFromEventDetailViewController(segue: UIStoryboardSegue) {
        self.tableView.reloadData()
    }

    @IBAction func unwindFromCreateTripViewController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func onTripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        trips = getTrips(for: tripSegment(rawValue: sender.selectedSegmentIndex)!)
        tableView.reloadData()
    }
    
    func getTrips(for trip: tripSegment) -> [Trip] {
        
        var trips: [Trip] = []
        
        let today = Calendar.current.startOfDay(for: Date())
        let low = today + TimeInterval(selectedDay * 60 * 60 * 24)
        let high = low + TimeInterval(60 * 60 * 24)
        
        
        switch trip {
        case .myTrips:
            trips = self.myTrips.filter{ $0.event.time >= low && $0.event.time <= high }.sorted()
        case .friendsTrips:
            trips = self.myFriendsTrips.filter{ $0.event.time >= low && $0.event.time <= high }.sorted()
        }
        
        return trips
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = trips[indexPath.row]
        let dsc = trip.event.description == "" ? "No description given" : trip.event.description
        //let kid = trip.children[indexPath.row]
        cell.grandmaLabel.text = dsc
        //cell.kidNames.text = kid.name

        if dsc == "" {
            cell.grandmaLabel.font = UIFont.italicSystemFont(ofSize: (cell.grandmaLabel.font.pointSize))
        } else {
            cell.grandmaLabel.font = UIFont.boldSystemFont(ofSize: cell.grandmaLabel.font.pointSize)
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
        performSegue(withIdentifier: "segueToEventDetailVC", sender: trip)
    }
    
    
}

