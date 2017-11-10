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
    
    var desc: String = ""
    var time: Date = Date()
    var enteredLocation: String = ""
    var locationFromMap: CLLocation?
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var annotations: [MKAnnotation] = []
    var child: Child?
    
    
    
    
    enum selectedLeg: Int {
        case dropoff
        case pickup
        
        var descComponent: String {
            switch self {
            case .dropoff:
                return " dropped off at"
            case .pickup:
                return " picked up by"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    @IBAction func onCreateTripPressed(_ sender: UIButton) {
        //print("Time\(time), Description\(desc)")
        if desc != ""{
            API.createTrip(eventDescription: desc, eventTime: time, eventLocation: locationFromMap) { result in
                switch result {
                case .success(let trip):
                    if let child = self.child {
                        do {
                            try API.add(child: child, to: trip)
                        } catch {
                            let alert = UIAlertController(title: "Whoops", message: "Child was not added", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "I'll try again!", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .failure(_):
                    let alert = UIAlertController(title: "Whoops", message: "Trip Creation Failed", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay, I'll try again!", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                self.performSegue(withIdentifier: "unwindCreateTrip", sender: self)
            }
        }
    }
    
    @IBAction func onDatePickerChanged(_ sender: UIDatePicker) {
        time = sender.date
        //todo error if the date is bad
    }
    
    @IBAction func onChildNameEntered(_ sender: UITextField) {
        if let enteredText = sender.text {
            API.addChild(name: enteredText, completion: { (result) in
                switch result {
                    
                case .success(let child):
                    self.child = child
                case .failure(_):
                    break//TODO error
                }
            })
        } else {
            let alert = UIAlertController(title: "Whoops", message: "Please enter a child's name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onDestinationAdded(_ sender: UITextField) {
        //let mappableDestination = MK
        
        if let enteredText = sender.text {
            
            enteredLocation = enteredText
            desc = enteredText
            
            let geocoder = CLGeocoder()
            let clRegion = CLCircularRegion(center: currentLocation.coordinate, radius: 20000, identifier: "currentLocation")
            
            geocoder.geocodeAddressString(enteredText, in: clRegion, completionHandler: { (placemarks, error) in
                if let placemarks = placemarks {
                    self.annotations = placemarks.map({$0.location!})
                    print("We have locations")
                    self.mapButton.isHidden = false
                } else {
                    print(#function, "Something went bad")
                    self.mapButton.isHidden = true
                }
            })
            
//            let searchRequest = MKLocalSearchRequest()
//            searchRequest.naturalLanguageQuery = enteredText
//            searchRequest.region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 20000, 20000)
//
//            let search = MKLocalSearch(request: searchRequest)
//
//            search.start { (searchResp, error) in
//                if let searchResp = searchResp {
//                    print("WE HAVE THE STUFF!")
//                    self.annotations = searchResp.mapItems.map({ $0.placemark })
//                    self.mapButton.isHidden = false
//                    //we have annotations
//                } else {
//                    print("Haha, you've been swindled")
//                    self.mapButton.isHidden = true
//                    //we don't have annotations, todo errors
//                }
//            }
        }
    }
    @IBAction func onMapItPressed(_ sender: UIButton) {
        //TODO take entered text from destination added and add it to CL Location
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let searchLocationVC = segue.destination as? SearchLocationViewController {
            searchLocationVC.annotations = annotations
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
        dateFormatter.dateFormat = "ha"
        return dateFormatter.string(from: self)
    }
}

extension Trip {
    
    var generateSmartDescription: String {
        
        var kidSubString = "NameYourFkinChild"
        
        if children.count > 0 {
            kidSubString =  children[0].name
            if children.count == 2 {
                kidSubString = "\(children[0].name) and \(children[1].name)"
            } else {
                kidSubString = "\(children[0].name) and \(children.count - 2) other kids"
            }
        }
        return "On \(event.time.day), \(kidSubString) will be going to \(event.description) at \(event.time.time)"
    }
}

extension CreateTripViewController: MKMapViewDelegate {
    
}


extension CreateTripViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

extension CLLocation: MKAnnotation {

}

