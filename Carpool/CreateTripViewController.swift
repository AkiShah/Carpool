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
    
    @IBOutlet weak var childScroller: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
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
    
    @IBAction func onCancelPressed(_ sender: UIButton) {
        enteredLocation = ""
        
    }
    
    //The createTrip button is pressed here
    @IBAction func onCreateTripPressed(_ sender: UIButton) {
        //print("Time\(time), Description\(desc)")
        if desc != ""{
            API.createTrip(eventDescription: desc, eventTime: time, eventLocation: locationFromMap) { result in
                switch result {
                case .success(let trip):
                    if let child = self.child {
                        do {
                            try API.add(child: child, to: trip)
                            self.performSegue(withIdentifier: "unwindCreateTrip", sender: self)
                        } catch {
                            print(error)
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
            }
        }
    }
    
    @IBAction func onDatePickerChanged(_ sender: UIDatePicker) {
        time = sender.date
    }
    
    //This shouldn't happen until after the trip is created.
    @IBAction func onChildNameEntered(_ sender: UITextField) {
        if let enteredText = sender.text {
            API.addChild(name: enteredText, completion: { (result) in
                switch result {
                    
                case .success(let child):
                    self.child = child
                case .failure(_):
                    let alert = UIAlertController(title: "Whoops", message: "Please enter a child's name", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: "Whoops", message: "Please enter a child's name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Thanks, I'll do that!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //When you click ENTER on the destination field
    @IBAction func onDestinationAdded(_ sender: UITextField) {
        //let mappableDestination = MK
        
        if let enteredText = sender.text {
            //AND there is a child selected
            
            enteredLocation = enteredText
            desc = enteredText
            let geocoder = CLGeocoder()
            
            //need clRegion to display coordinate around current annotation, we don't need user's current location
            let clRegion = CLCircularRegion(center: currentLocation.coordinate, radius: 50000, identifier: "currentLocation")
   
            geocoder.geocodeAddressString(enteredText, in: clRegion, completionHandler: { (placemarks, error) in
                if let placemarks = placemarks {
                    self.annotations = placemarks.map({$0.location!})
                    print("We have locations")
                    
                    self.mapButton.isHidden = false
                    self.instructionLabel.isHidden = false
                } else {
                    print(#function, "Something went bad, no locations for you")
                    self.mapButton.isHidden = true
                    self.instructionLabel.isHidden = true
                }
                if let error = error {
                    let alert = UIAlertController(title: "Whoops", message: "I couldn't find that location. Try a specific address. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print(error)
                }
            })
        }
    }
    @IBAction func onMapItPressed(_ sender: UIButton) {
        
        //TODO take entered text from destination added and add it to CL Location
    }
    
    @IBAction func onSegmentedControlPressed(_ sender: UISegmentedControl) {
        //pickup or drop off
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let searchLocationVC = segue.destination as? MapViewController {
            searchLocationVC.annotations = annotations
        }
    }
    
    @IBAction func unwindFromSearchLocationMap(segue: UIStoryboardSegue) {
        if let searchLocationVC = segue.destination as? MapViewController {
            if let location = searchLocationVC.selectedLocation {
                locationFromMap = location
            }
        }
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
        currentLocation = locations.first!
    }
}

extension CLLocation: MKAnnotation {

}




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
