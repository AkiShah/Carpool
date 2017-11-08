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
import MapKit

class CreateTripViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapButton: UIButton!
    
    let location: CLLocation = CLLocation()
    var desc: String = ""
    var time: Date = Date()
    var enteredLocation: String = ""
    var childName: String = ""
    var locationFromMap: CLLocation?
    
    
    enum selectedLeg: Int {
        case dropoff
        case pickup
        
        var descComponent: String {
            switch self {
            case .dropoff:
                return "dropped off at"
            case .pickup:
                return "picked up by"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        
    }
    
    @IBAction func onCreateTripPressed(_ sender: UIButton) {
        print("Time\(time), Description\(desc)")
        if desc != ""{
            API.createTrip(eventDescription: desc, eventTime: time, eventLocation: locationFromMap) { trip in
                print(trip)
                print("Trip created")
                self.performSegue(withIdentifier: "unwindCreateTrip", sender: self)
            }
        }
    }
    
    @IBAction func onDatePickerChanged(_ sender: UIDatePicker) {
        time = sender.date
        //todo error if the date is bad
    }
    
    @IBAction func onChildNameEntered(_ sender: UITextField) {
        let enteredText = sender.text
        
        if enteredText?.isEmpty ?? true {
            let alert = UIAlertController(title: "Whoops", message: "Please enter a child's name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onDestinationAdded(_ sender: UITextField) {
        //let mappableDestination = MK
        
        if let enteredText = sender.text {
            mapButton.isHidden = false
            enteredLocation = enteredText
            desc = enteredText
        }
//        if destinationDisplayed.text?.isEmpty ?? true {
//            let alert = UIAlertController(title: "Whoops", message: "Please enter a valid destination", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    @IBAction func onMapItPressed(_ sender: UIButton) {
        //TODO take entered text from destination added and add it to CL Location
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let searchLocationVC = segue.destination as? SearchLocationViewController {
            searchLocationVC.query = enteredLocation
        }
    }
    
    @IBAction func unwindFromSearchLocationMap(segue: UIStoryboardSegue) {
        if let searchLocationVC = segue.destination as? SearchLocationViewController {
            if let location = searchLocationVC.selectedLocation {
                locationFromMap = location
            }
        }
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

extension Event {
    
    var generateSmartDescription: String {
        //let desc = "On \(time.day), Kai needs to be \(selectedLeg(rawValue: segmentedControl.selectedSegmentIndex)!.descComponent) \(description) by \(time.time)"
        return "On \(time.day), Kai will be going to \(time.time)"
    }
}

