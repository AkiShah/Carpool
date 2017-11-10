//
//  EventDetailViewController.swift
//  Carpool
//
//  Created by Akash Shah on 11/6/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit
import CarpoolKit
import CoreLocation

class TripDetailViewController: UIViewController {
    
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventPickupDriverLabel: UILabel!
    @IBOutlet weak var eventDropoffDriverLabel: UILabel!
    @IBOutlet weak var pickupButton: UIButton!
    @IBOutlet weak var dropoffButton: UIButton!
    
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

        eventDescriptionLabel.text = trip.event.description
        
        updateButtonState(for: .dropoff)
        updateButtonState(for: .pickup)
        
        let geocoder = CLGeocoder()
        if let location = trip.event.clLocation {
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let state = placemarks?.first?.administrativeArea, let city = placemarks?.first?.locality{
                    self.eventLocationLabel.text = "\(city), \(state)"
                } else if let error = error {
                    self.errorMessages(error: error)
                }
            }
        }
        
        let formatter = DateFormatter()
        //Need to check if this comes out as Time
        formatter.dateFormat = "h : mm"
        eventTimeLabel.text = formatter.string(from: trip.event.time)
        
    }

    //TODO Give button a selected and unselected case to simplify further
    
    func updateButtonState(for leg: TripLeg) {
        let claimStatus = isLegClaimed(tripLeg: leg == .dropoff ? trip.dropOff : trip.pickUp)
        
        switch (leg, claimStatus) {
        case (.dropoff, .claimed):
            let driver = trip.dropOff!.driver
            API.fetchCurrentUser(completion: { result in
                switch result {
                case .success(let user):
                    print("Neer mind, you can haz this leg back")
                    self.dropoffButton.isEnabled = user == driver
                case .failure:
                    //TODO Error Handling
                    break
                }
            })
            dropoffButton.setTitle("Drop Off Claimed", for: .normal)
            eventDropoffDriverLabel.text = driver.name
        case (.dropoff, .unclaimed):
            dropoffButton.isEnabled = true
            print("I hereby claim this leg as mine")
            dropoffButton.setTitle("Claim Drop Off", for: .normal)
        case (.pickup, .claimed):
            let driver = trip.pickUp!.driver
            API.fetchCurrentUser(completion: { result in
                switch result {
                case .success(let user):
                    print("Neer mind, you can haz this leg back")
                    self.pickupButton.isEnabled = user == driver
                case .failure:
                    //TODO Error Handling
                    break
                }
            })
            pickupButton.setTitle("Pickup Claimed", for: .normal)
            eventPickupDriverLabel.text = driver.name
        case (.pickup, .unclaimed):
            pickupButton.isEnabled = true
            print("I hereby claim this leg as mine")
            pickupButton.setTitle("Claim Pickup", for: .normal)
        }
    }
    
    @IBAction func onDropoffButtonPressed(_ sender: UIButton) {
        switch isLegClaimed(tripLeg: trip.dropOff) {
            
        case .claimed:
            API.unclaimPickUp(trip: trip, completion: pickUpClaimChanged)
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
            API.unclaimPickUp(trip: trip, completion: dropOffClaimChanged)
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
            print("Look mom I made a change")
            updateButtonState(for: .dropoff)
        }
        
    }
    
    
    func pickUpClaimChanged(error: Error?) {
        if let error = error {
            errorMessages(error: error)
        } else {
            print("Look mom I made a change")
            updateButtonState(for: .pickup)
        }
        
    }
    
    func errorMessages(error: Error) {
        let alert = UIAlertController(title: "Whoops", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'll try again", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}





