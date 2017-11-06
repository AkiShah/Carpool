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

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventPickupDriverLabel: UILabel!
    @IBOutlet weak var eventDropoffDriverLabel: UILabel!
    
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventDescriptionLabel.text = trip.event.description
        eventPickupDriverLabel.text = trip.pickUp.driver?.name
        eventDropoffDriverLabel.text = trip.dropOff.driver?.name
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(trip.event.location) { placemarks, error in
            //Change to address
            if let state = placemarks?.first?.administrativeArea, let city = placemarks?.first?.locality{
                self.eventLocationLabel.text = "\(city), \(state)"
            }
        }
        let formatter = DateFormatter()
        //Need to check if this comes out as Time
        formatter.dateFormat = "h : m"
        eventTimeLabel.text = formatter.string(from: trip.event.time)
        
    }
}
