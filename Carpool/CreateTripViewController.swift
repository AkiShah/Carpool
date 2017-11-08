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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var destinationDisplayed: UILabel!
    @IBOutlet weak var onSearchForRouteEntered: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapButton: UIButton!
    
    let location: CLLocation = CLLocation()
    var desc: String = ""
    var time: Date!
    var enteredLocation: String = ""
    var childName: String = ""
    
    
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
    
    @IBAction func onChildNameEntered(_ sender: UITextField) {
        let enteredText = sender.text
        
        if enteredText?.isEmpty ?? true {
            let alert = UIAlertController(title: "Whoops", message: "Please enter a child's name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onDestinationAdded(_ sender: UITextField) {
        if let enteredText = sender.text {
            mapButton.isHidden = false
            enteredLocation = enteredText
        }
        if destinationDisplayed.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Whoops", message: "Please enter a valid destination", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func onMapItPressed(_ sender: UIButton) {
        //TODO take entered text from destination added and add it to CL Location
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        
    }
    func generateDescription() -> String{
        //        “On Monday, Johnny needs to be picked up from Savannah Soccer Fields by 8pm”
        //ToggleState(rawValue: sender.selectedSegmentIndex)
        let desc = "On \(time.day), \(childName) needs to be \(selectedLeg(rawValue: segmentedControl.selectedSegmentIndex)!.descComponent) \(enteredLocation) by \(time.time)"
        return desc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let searchLocationVC = segue.destination as? SearchLocationViewController {
            searchLocationVC.query = enteredLocation
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

