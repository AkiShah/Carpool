//
//  AkiTripDetailViewController.swift
//  Carpool
//
//  Created by Akash Shah on 11/15/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit
import CarpoolKit
import CoreLocation

class AkiTripDetailViewController: UITableViewController {
    
    //Header
    @IBOutlet weak var eventDestinationLabel: UILabel!
    @IBOutlet weak var eventDestinationAddressButton: UIButton!
    
    //Event Date and Times
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    
    @IBOutlet weak var eventChildrenLabel: UILabel!
    
    //Drivers Labels and Buttons
    @IBOutlet weak var eventDropoffDriverLabel: UILabel!
    @IBOutlet weak var eventDropoffButton: UIButton!
    @IBOutlet weak var eventPickupDriverLabel: UILabel!
    @IBOutlet weak var eventPickupButton: UIButton!
    
    //Footer
    @IBOutlet weak var eventCommentTextView: UITextView!
    
    var trip: Trip!
    
    enum TripLeg {
        case dropoff
        case pickup
    }
    
    enum isLegClaimed {
        case claimed
        case unclaimed
        
        var rawValue: Bool {
            switch self {
            case .claimed:
                return true
            case .unclaimed:
                return false
            }
        }
        init (tripLeg: Leg?) {
            self = tripLeg != nil ? .claimed : .unclaimed
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.observe(trip: trip, sender: self) { result in
            switch result {
            case .success(let trip):
                self.trip = trip
                self.updateTripDetails(using: trip)
                
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Whoops", message: "Couldn't create a new trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    @IBAction func onEventDestinationAddressButtonClicked(_ sender: UIButton) {
        //Go to map
        
    }
    
    @IBAction func onDropoffButtonClicked(_ sender: UIButton) {
        switch isLegClaimed(tripLeg: trip.dropOff) {
            
        case .claimed:
            API.unclaimDropOff(trip: trip, completion: dropOffClaimChanged)
        case .unclaimed:
            let alert = UIAlertController(title: "Claim this Dropoff", message: "Would you like to claim this dropoff?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Claim Dropoff", style: .default, handler: {_ in
                API.claimDropOff(trip: self.trip, completion: self.dropOffClaimChanged)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPickupButtonPressed(_ sender: UIButton) {
        switch isLegClaimed(tripLeg: trip.pickUp) {
        case .claimed:
            let alert = UIAlertController(title: "Unclaim this Pickup", message: "Would you like to unclaim this pickup?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Unclaim Pickup", style: .default, handler: { _ in
                API.claimPickUp(trip: self.trip, completion: self.pickUpClaimChanged)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .unclaimed:
            let alert = UIAlertController(title: "Claim this Pickup", message: "Would you like to claim this pickup?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Claim Pickup", style: .default, handler: { _ in
                API.claimPickUp(trip: self.trip, completion: self.dropOffClaimChanged)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func dropOffClaimChanged(error: Error?) {
        if let error = error {
            errorMessages(error: error)
        } else {
            print("Look mom, I made a change")
        }
        
    }
    
    func pickUpClaimChanged(error: Error?) {
        if let error = error {
            errorMessages(error: error)
        } else {
            print("Look mom, I made a change")
        }
        
    }
    
    func errorMessages(error: Error) {
        let alert = UIAlertController(title: "Whoops", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'll try again", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onPostCommentButtonClicked(_ sender: UIButton) {
        API.add(comment: eventCommentTextView.text, to: trip)
    }
    
    func updateTripDetails(using trip: Trip) {
    
        eventDestinationLabel.text = trip.event.description
        
        let geocoder = CLGeocoder()
        if let location = trip.event.clLocation {
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                //Display Address
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM ee"
        eventDateLabel.text = formatter.string(from: trip.event.time)
        formatter.dateFormat = "h : mm"
        eventStartTimeLabel.text = formatter.string(from: trip.event.time)
        eventEndTimeLabel.text = trip.event.endTime != nil ? formatter.string(from: trip.event.endTime!) : "--"
    
        //Wtf is this?
        //if trip.clamped(to: <#T##Range<Trip>#>)
        
        if trip.children.count > 0 {
            let childrenNames = trip.children.map({$0.name}).sorted(by: {$0 < $1})
            var childString = childrenNames.joined(separator: ", ")
            
            if let lastCommaRange = childString.range(of: ", ", options: .backwards) {
                childString.replaceSubrange(lastCommaRange, with: " and ")
            }
            eventChildrenLabel.text = childString
        }
        
        updateButtonState(for: .dropoff)
        updateButtonState(for: .pickup)
        tableView.reloadData()
        
    }
    
    func updateButtonState(for leg: TripLeg) {
        let claimStatus = isLegClaimed(tripLeg: leg == .dropoff ? trip.dropOff : trip.pickUp)
        
        switch (leg, claimStatus) {
        case (.dropoff, .claimed):
            let driver = trip.dropOff!.driver
            API.fetchCurrentUser(completion: { result in
                switch result {
                case .success(let user):
                    self.eventDropoffButton.isEnabled = user == driver
                case .failure(let error):
                    let alert = UIAlertController(title: "Whoops", message: "Couldn't unclaim that trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    break
                }
            })
            eventDropoffButton.setTitle("Drop Off Claimed", for: .normal)
            eventDropoffDriverLabel.text = driver.name
            eventDropoffButton.tintColor = UIColor.red
        case (.dropoff, .unclaimed):
            eventDropoffButton.isEnabled = true
            print("I hereby claim this leg as mine")
            eventDropoffButton.setTitle("Claim Drop Off", for: .normal)
            eventDropoffButton.tintColor = UIColor.blue
        case (.pickup, .claimed):
            let driver = trip.pickUp!.driver
            API.fetchCurrentUser(completion: { result in
                switch result {
                case .success(let user):
                    self.eventPickupButton.isEnabled = user == driver
                case .failure(let error):
                    let alert = UIAlertController(title: "Whoops", message: "Couldn't claim that trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    break
                }
            })
            eventPickupButton.setTitle("Pickup Claimed", for: .normal)
            eventPickupDriverLabel.text = driver.name
            eventPickupButton.tintColor = UIColor.red
        case (.pickup, .unclaimed):
            eventPickupButton.isEnabled = true
            print("I hereby claim this leg as mine")
            eventPickupButton.setTitle("Claim Pickup", for: .normal)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        cell.textLabel?.text = trip.comments[indexPath.row].body
        cell.detailTextLabel?.text = trip.comments[indexPath.row].user.name
        return cell
    }
    
}
