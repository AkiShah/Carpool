//
//  AkiCreateTripViewController.swift
//  
//
//  Created by Akash Shah on 11/16/17.
//

import Foundation
import UIKit
import CarpoolKit
import CoreLocation
import MapKit

class AkiCreateTripViewController: UIViewController, MKLocalSearchCompleterDelegate {
    
    
    @IBOutlet weak var tripDestinationTextField: UITextField!
    @IBOutlet weak var tripDestinationMapButton: UIButton!
    
    @IBOutlet weak var tripSelectedDayButton: UIButton!
    @IBOutlet weak var tripSelectedStartTimeButton: UIButton!
    @IBOutlet weak var tripSelectedEndTimeButton: UIButton!
    @IBOutlet weak var tripDatePicker: UIDatePicker!
    @IBOutlet weak var tripRepeatButton: UIButton!
    
    @IBOutlet weak var tripChildrenCollectionView: UICollectionView!
    
    
    var destination: String = ""
    var location: CLLocation?
    var date: Date =  Date()
    var startTime: Date =  Date()
    var endTime: Date =  Date()
    var repeatTrip: Bool = false
    var kids: [Child] = []
    var kidsOnTrip: [Child] = []
    var selectedButton: DayOrTime = .disabled
    var resultingLocations: [MKMapItem] = []
    
    enum DayOrTime {
        case day
        case startTime
        case endTime
        case disabled
    }
    
    //Locations
    let locationManager = CLLocationManager()
    let localSearchCompleter = MKLocalSearchCompleter()
    var myLocation: CLLocation?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeDatePicker(to: .disabled)
        self.tripDestinationMapButton.isEnabled = false
        
        tripChildrenCollectionView.delegate = self
        tripChildrenCollectionView.dataSource = self
        tripChildrenCollectionView.allowsMultipleSelection = true
        
        tripDestinationTextField.layer.masksToBounds = true
        tripDestinationTextField.layer.cornerRadius = 10
        tripDestinationTextField.backgroundColor = darkBlue
        tripDestinationTextField.textColor = lightOrange
        
        tripDestinationMapButton.layer.masksToBounds = true
        tripDestinationMapButton.layer.cornerRadius = 10
        
//        tripRepeatButton.setTitle("Repeat Every Week Off", for: .normal)
//        tripRepeatButton.setTitleColor(lightOrange, for: .normal)
//        tripRepeatButton.backgroundColor = darkBlue
        tripRepeatButton.layer.masksToBounds = true
        tripRepeatButton.layer.cornerRadius = 10
        
        tripDatePicker.setValue(darkBlue, forKeyPath: "textColor")
        tripDatePicker.backgroundColor = lightOrange
        
        API.fetchCurrentUser(completion: { result in
            switch result {
            
            case .success(let user):
                self.kids = user.children
                self.tripChildrenCollectionView.reloadData()
            case .failure(let error):
                //TODO error handling
                print(#function, error)
            }
        })
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        localSearchCompleter.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let searchLocationVC = segue.destination as? MapViewController {
            
            var coordinates: [CLLocationCoordinate2D] = []
            var filteredLocations: [MKMapItem] = []
            for location in resultingLocations {
                if !coordinates.contains(location.coordinate){
                    coordinates.append(location.coordinate)
                    filteredLocations.append(location)
                }
            }
            searchLocationVC.annotations = filteredLocations
        }
    }
    
    @IBAction func unwindFromSearchLocationMap(segue: UIStoryboardSegue) {
        if let searchLocationVC = segue.destination as? MapViewController {
            if let location = searchLocationVC.selectedLocation {
                self.location = location
            }
        }
    }
    
    @IBAction func onSelectedTripDayButtonPressed(_ sender: UIButton) {
        changeDatePicker(to: .day)
    }
    
    @IBAction func onSelectedTripStartTimeButtonPressed(_ sender: UIButton) {
        changeDatePicker(to: .startTime)
    }
    
    @IBAction func onSelectedTripEndTimeButtonPressed(_ sender: UIButton) {
        changeDatePicker(to: .endTime)
    }
    
    
    
    func changeDatePicker(to newSelection: DayOrTime) {
        
        tripSelectedDayButton.backgroundColor = darkBlue
        tripSelectedStartTimeButton.backgroundColor = darkBlue
        tripSelectedEndTimeButton.backgroundColor = darkBlue
        
        tripSelectedDayButton.setTitleColor(lightOrange, for: .normal)
        tripSelectedStartTimeButton.setTitleColor(lightOrange, for: .normal)
        tripSelectedEndTimeButton.setTitleColor(lightOrange, for: .normal)
        
        switch newSelection {
        case .day:
            tripDatePicker.isHidden = false
            tripDatePicker.datePickerMode = .date
            tripSelectedDayButton.backgroundColor = lightOrange
            tripSelectedDayButton.setTitleColor(darkBlue, for: .normal)
            
        case .startTime:
            tripDatePicker.isHidden = false
            tripDatePicker.datePickerMode = .time
            tripSelectedStartTimeButton.backgroundColor = lightOrange
            tripSelectedStartTimeButton.setTitleColor(darkBlue, for: .normal)
            
        case .endTime:
            tripDatePicker.isHidden = false
            tripDatePicker.datePickerMode = .time
            tripSelectedEndTimeButton.backgroundColor = lightOrange
            tripSelectedEndTimeButton.setTitleColor(darkBlue, for: .normal)

        case .disabled:
            tripDatePicker.isHidden = true
        }
        selectedButton = newSelection
    }
    
    @IBAction func onDatePickerValueChanged(_ sender: UIDatePicker) {
        switch selectedButton{
        case .day:
            date = sender.date
            tripSelectedDayButton.setTitle(date.date, for: .normal)
        case .startTime:
            tripSelectedStartTimeButton.setTitle(startTime.time, for: .normal)
            startTime = sender.date
        case .endTime:
            tripSelectedEndTimeButton.setTitle(startTime.time, for: .normal)
            endTime = sender.date
        case .disabled:
            break
        }
    }
    @IBAction func onDestionationDidEndOnExit(_ sender: UITextField) {
        changeDatePicker(to: .disabled)
        if let newDestination = sender.text {
            destination = newDestination
            sender.resignFirstResponder()
            searchforLocation(using: destination)
        }
    }
    
    
    func searchforLocation(using query: String) {
        if let myLocation = myLocation {
            let region = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, 10000, 10000)
            localSearchCompleter.region = region
            localSearchCompleter.queryFragment = query
            
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        
        
        let region = MKCoordinateRegionMakeWithDistance(myLocation!.coordinate, 10000, 10000)
        let request = MKLocalSearchRequest()
        request.region = region
        
        for query in results {
            request.naturalLanguageQuery = query.title
            
            let search  = MKLocalSearch(request: request)
            search.start(completionHandler: { response, error in
                guard let response = response else { return print(#function, error!) }
                self.resultingLocations.append(contentsOf: response.mapItems)
                self.tripDestinationMapButton.isEnabled = !completer.isSearching
            })
        }
        
        

        
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(#function, error)
    }
    
    @IBAction func onRepeatTripButtonPressed(_ sender: UIButton) {
        changeDatePicker(to: .disabled)
        repeatTrip = !repeatTrip
        
        switch repeatTrip {
        case true:
            tripRepeatButton.setTitle("REPEAT EVERY WEEK ON", for: .normal)
            tripRepeatButton.setTitleColor(darkBlue, for: .normal)
            tripRepeatButton.backgroundColor = lightOrange
        case false:
            tripRepeatButton.setTitle("REPEAT EVERY WEEK OFF", for: .normal)
            tripRepeatButton.setTitleColor(lightOrange, for: .normal)
            tripRepeatButton.backgroundColor = darkBlue
        }
    }
    
    @IBAction func onCreateTripButtonPressed(_ sender: UIButton) {
        
        if let destination = tripDestinationTextField.text, kidsOnTrip.count > 0{
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            let hour = calendar.component(.hour, from: startTime)
            let endHour = calendar.component(.hour, from: self.endTime)
            let minute = calendar.component(.minute, from: startTime)
            let endMinute = calendar.component(.minute, from: self.endTime)
            let seconds = calendar.component(.second, from: startTime)
            
            let components = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: seconds)
            let endTimeComponents = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: endHour, minute: endMinute, second: seconds)
            
            let eventTime: Date = components.date!
            let endTime: Date = endTimeComponents.date!
            API.createTrip(eventDescription: destination, eventTime: eventTime, eventLocation: location) { result in
                switch result {
                    
                case .success(let trip):
                    API.set(endTime: endTime, for: trip.event, completion: { error in
                        //print(#function, error)
                    })
                    API.mark(trip: trip, repeating: self.repeatTrip)
                    for child in self.kidsOnTrip {
                        do{
                            try API.add(child: child, to: trip)
                        } catch {
                            //TODO error handling
                            print(#function, error)
                        }
                    }
                    break
                case .failure(let error):
                    //TODO Error Handling
                    print(#function, error)
                }
            }
            
        } else {
            print(#function, destination)
        }
    }
}

extension AkiCreateTripViewController: MKMapViewDelegate {
    
}

extension AkiCreateTripViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       myLocation = locations.first!
        
    }
}

extension CLLocation: MKAnnotation {
    
}

extension MKMapItem: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return self.placemark.coordinate
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


extension Date {
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:m aa"
        return dateFormatter.string(from: self)
    }
    
}

extension Trip {
 
    var kidNamesString: String {
        
        if children.count > 0 {
            let childrenNames = children.map({$0.name}).sorted(by: {$0 < $1})
            let isAre = children.count == 1 ? "is" : "are"
            var childString = childrenNames.joined(separator: ", ")
            
            if let lastCommaRange = childString.range(of: ", ", options: .backwards) {
                childString.replaceSubrange(lastCommaRange, with: " and ")
            }
            
            return "\(childString) \(isAre) going to"
        } else {
            return "\(event.owner) is going to"
        }
        
    }
    
    var dayAndTimeOfEvent: String {
        if let endTime = event.endTime {
            return "On \(event.time.day) from \(event.time.time) to \(endTime.time)"
        }
        return "On \(event.time.day) at \(event.time.time)"
    }
}
