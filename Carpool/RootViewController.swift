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
    var tripsForDays: [[Trip]] = []
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
        calendarCollectionView.layer.masksToBounds = true
        calendarCollectionView.layer.cornerRadius = 10
        
        API.observeMyTrips(sender: self) { result in
            switch result {
            case .success(let trips):
                self.myTrips = trips
                self.separateTripsForDays(for: tripSegment(rawValue: self.TripSegmentedViewController.selectedSegmentIndex)!)
            case .failure(let error):
                //TODO error handling
                print(#function, error)
            }
        }
        API.observeTheTripsOfMyFriends(sender: self) { result in
            switch result {
            case .success(let trips):
                self.myFriendsTrips = trips
                self.separateTripsForDays(for: tripSegment(rawValue: self.TripSegmentedViewController.selectedSegmentIndex)!)
            case .failure(let error):
                //TODO error handling
                print(#function, error)
            }
        }
        separateTripsForDays(for: .myTrips)
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
        separateTripsForDays(for: tripSegment(rawValue: sender.selectedSegmentIndex)!)
        tableView.reloadData()
    }
    
    func separateTripsForDays (for trip: tripSegment) {
        let today = Calendar.current.startOfDay(for: Date())
        tripsForDays = []
        for day in 0...6 {
            let low = today + TimeInterval(day * 60 * 60 * 24)
            let high = low + TimeInterval(60 * 60 * 24)
            
            switch trip {
            case .myTrips:
                tripsForDays.append(self.myTrips.filter{ $0.event.time >= low && $0.event.time <= high }.sorted())
            case .friendsTrips:
                tripsForDays.append(self.myFriendsTrips.filter{ $0.event.time >= low && $0.event.time <= high }.sorted())
            }
        }
        tableView.reloadData()
        calendarCollectionView.reloadData()
        
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
        let trip = tripsForDays[selectedDay][indexPath.row]
        let dsc = trip.event.description == "" ? "No description given" : trip.event.description
        cell.grandmaLabel.text = dsc
        cell.kidsWhoAreGoingLabel.text = trip.kidNamesString
        cell.dayAndTimeLabel.text = trip.dayAndTimeOfEvent

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
            label.textColor = darkBlue
            label.backgroundColor = UIColor.clear
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
            if legType == .dropoff{
                carImage.image = #imageLiteral(resourceName: "carFaceRightBlue")
            } else {
                carImage.image = #imageLiteral(resourceName: "carFaceLeftBlue")
            }
        } else {
            label.text = "NOT CLAIMED"
            label.textColor = darkBlue
            label.backgroundColor = darkOrange
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
            if legType == .dropoff{
                carImage.image = #imageLiteral(resourceName: "carFaceRightFaded")
            } else {
                carImage.image = #imageLiteral(resourceName: "carFaceLeftFaded")
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tripsForDays[selectedDay].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let trip = tripsForDays[selectedDay][indexPath.row]
        performSegue(withIdentifier: "segueToEventDetailVC", sender: trip)
    }
    
    
}

