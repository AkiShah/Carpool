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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !trip.pickUp.isClaimed{
            pickupButton.isEnabled = true
            pickupButton.setTitle("Claim Pickup", for: .normal)
        } else {
            pickupButton.isEnabled = false
            pickupButton.setTitle("Pickup Claimed", for: .normal)
        }
        if !trip.dropOff.isClaimed{
            dropoffButton.isEnabled = true
            dropoffButton.setTitle("Claim Drop Off", for: .normal)
        } else {
            dropoffButton.isEnabled = false
            dropoffButton.setTitle("Drop Off Claimed", for: .normal)
        }
        
        eventDescriptionLabel.text = trip.event.description
        eventPickupDriverLabel.text = trip.pickUp.driver?.name
        eventDropoffDriverLabel.text = trip.dropOff.driver?.name
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(trip.event.location) { placemarks, error in
            if let state = placemarks?.first?.administrativeArea, let city = placemarks?.first?.locality{
                self.eventLocationLabel.text = "\(city), \(state)"
            }
        }
        let formatter = DateFormatter()
        //Need to check if this comes out as Time
        formatter.dateFormat = "h : m"
        eventTimeLabel.text = formatter.string(from: trip.event.time)
        
    }
    
    
    
    @IBAction func onPickupButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Claim this Pickup", message: "Would you like to claim this pickup?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Claim Pickup", style: .default, handler: { _ in
                    API.claimLeg(leg: self.trip.pickUp, trip: self.trip, completion: { (error) in
                        print("completed")
                        if let error = error{
                            print(error)
                        }
                    })
        }))
        //alert.addAction(UIAlertAction(title: "Claim Pickup", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

//        API.claimLeg(leg: self.trip.pickUp, trip: self.trip, completion: { (error) in
//            if let error = error{
//                print(error)
//            } else{
//                print("completed")
//            }
//        })
        
    }
    @IBAction func onDropoffButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Claim this Dropoff", message: "Would you like to claim this dropoff?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Claim Dropoff", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
