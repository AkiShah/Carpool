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

        eventDescriptionLabel.text = trip.event.description
        
        if let leg = trip.pickUp {
            pickupButton.isEnabled = false
            pickupButton.setTitle("Pickup Claimed", for: .normal)
            eventPickupDriverLabel.text = leg.driver.name
        } else {
            pickupButton.isEnabled = true
            pickupButton.setTitle("Claim Pickup", for: .normal)
        }
        if let leg = trip.dropOff {
            dropoffButton.isEnabled = false
            dropoffButton.setTitle("Drop Off Claimed", for: .normal)
            eventDropoffDriverLabel.text = leg.driver.name
        } else {
            dropoffButton.isEnabled = true
            dropoffButton.setTitle("Claim Drop Off", for: .normal)
        }
        
        let geocoder = CLGeocoder()
        if let location = trip.event.clLocation {
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let state = placemarks?.first?.administrativeArea, let city = placemarks?.first?.locality{
                    self.eventLocationLabel.text = "\(city), \(state)"
                } else {
                    self.errorMessages(error: error)
                }
            }
        }
        
        let formatter = DateFormatter()
        //Need to check if this comes out as Time
        formatter.dateFormat = "h : mm"
        eventTimeLabel.text = formatter.string(from: trip.event.time)
        
    }

    
    @IBAction func onPickupButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Claim this Pickup", message: "Would you like to claim this pickup?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Claim Pickup", style: .default, handler: { _ in
            
            API.claimPickUp(trip: self.trip, completion: { error in
                if let error = error{
                    print(error)
                    self.errorMessages(error: error)
                } else {
                    self.eventPickupDriverLabel.text = "Aki"
                    self.pickupButton.isEnabled = false
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func onDropoffButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Claim this Dropoff", message: "Would you like to claim this dropoff?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Claim Dropoff", style: .default, handler: {_ in
            API.claimDropOff(trip: self.trip, completion: { error in
                if let error = error{
                    print(error)
                    self.errorMessages(error: error)
                } else {
                    self.eventDropoffDriverLabel.text = "Shannon"
                    self.dropoffButton.isEnabled = false
                }
            })
            
        }))
        alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorMessages(error: Error?) {
        if let msg = error?.localizedDescription {
            let alert = UIAlertController(title: "Whoops", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I'll try again", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else {
            title = "OOOOHH NOOOOO"
        }
    }
}





