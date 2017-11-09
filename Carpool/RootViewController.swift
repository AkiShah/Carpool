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
    
    enum tripLeg: String {
        case dropoff = "will handle dropoff"
        case pickup = "will handle pickup"
    }
    
    enum tripSegment: Int {
        case myTrips
        case friendsTrips
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //would like to create a title for header in section splitting out which trips already have both legs claimed, and another section that displays which routes still have an unclaimed leg. That way you don't click on a trip that has both legs already accounted for.
        
        
        API.observeTrips { result in
            switch result {
            case .success(let trips):
                self.downloadedTrips = trips
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
    
    @IBAction func onTripSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch tripSegment(rawValue: sender.selectedSegmentIndex)! {
            
        case .myTrips:
            //let user = API.fetchUser(id: <#T##String#>, completion: <#T##(Result<User>) -> Void#>)
            trips = downloadedTrips.flatMap({_ in
                
                return nil
                //if $0.event.owner
            })
        case .friendsTrips:
            break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = trips[indexPath.row]
        let dsc = trip.event.description == "" ? "No description given" : trip.event.description
        cell.descriptionLabel.text = dsc
        
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
        } else {
            label.text = "Not Claimed"
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.red
            label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
            //carImage.image. = UIColor(white: 1, alpha: 0.6)
            
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

