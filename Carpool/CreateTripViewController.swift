//
//  CreateTripViewController.swift
//  Carpool
//
//  Created by Zaller on 11/6/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import CarpoolKit
import CoreLocation

class CreateTripViewController: UIViewController {
    
    @IBOutlet weak var destinationDisplayed: UILabel!
    @IBOutlet weak var onSearchForRouteEntered: UITextField!
    
    let location: CLLocation = CLLocation()
    var desc: String = ""
    var time: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onCreateTripPressed(_ sender: UIButton) {
    }
    
    @IBAction func onSearchRouteEntered(_ sender: UITextField) {
    }
     
    @IBAction func onNewTripDescriptionUpdated(_ sender: UITextField) {
    }
    
    func createNewTrip(at location: CLLocation, for description: String, when time: Date ){
        
        API.createTrip(eventDescription: description, eventTime: time, eventLocation: location) { trip in
            print(trip)
        }
    }
}
