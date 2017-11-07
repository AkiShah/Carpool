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
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let location: CLLocation = CLLocation()
    var desc: String = ""
    var time: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        
    }
    
    @IBAction func onCreateTripPressed(_ sender: UIButton) {
        print("Time\(time), Description\(desc)")
        if let time = time, desc != ""{
            API.createTrip(eventDescription: desc, eventTime: time, eventLocation: location) { trip in
                print(trip)
                print("Trip created")
                self.performSegue(withIdentifier: "unwindCreateTrip", sender: self)
            }
        }
    }
    @IBAction func onDatePickerChanged(_ sender: UIDatePicker) {
        time = sender.date
        
    }
    
    @IBAction func onNewTripTitleAdded(_ sender: UITextField) {
    }
    @IBAction func onNewTripDescriptionAdded(_ sender: UITextField) {
        print(sender.text)
        if let text = sender.text {
            desc = text
        }
    }
    
    func generateDescription() {
//        “On Monday, Johnny needs to be picked up from Savannah Soccer Fields by 8pm”
        
    }
    
}

extension Date {
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hha"
        return dateFormatter.string(from: self)
    }
}

