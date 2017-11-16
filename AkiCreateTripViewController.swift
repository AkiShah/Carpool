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

class AkiCreateTripViewController: UIViewController {
    
    
    @IBOutlet weak var tripDestinationTextField: UITextField!
    @IBOutlet weak var tripDestinationMapButton: UIButton!
    
    @IBOutlet weak var tripSelectedDayButton: UIButton!
    @IBOutlet weak var tripSelectedStartTimeButton: UIButton!
    @IBOutlet weak var tripSelectedEndTimeButton: UIButton!
    @IBOutlet weak var tripDatePicker: UIDatePicker!
    @IBOutlet weak var tripRepeatButton: UIButton!
    
    @IBOutlet weak var tripChildrenCollectionView: UICollectionReusableView!
    
    
    var destination: String = ""
    var location: CLLocation?
    var date: Date =  Date()
    var startTime: Date =  Date()
    var endTime: Date =  Date()
    var repeatTrip: Bool = false
    var kidsOnTrip: [Child] = []
    var selectedButton: DayOrTime = .disabled
    
    enum DayOrTime {
        case day
        case startTime
        case endTime
        case disabled
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeDatePicker(to: .disabled)
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
        switch newSelection {
        case .day:
            tripDatePicker.isHidden = false
            tripDatePicker.datePickerMode = .date
            
        case .startTime, .endTime:
            tripDatePicker.isHidden = false
            tripDatePicker.datePickerMode = .time

        case .disabled:
            tripDatePicker.isHidden = true
            break
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
    
    @IBAction func onDestinationEntered(_ sender: UITextField, forEvent event: UIEvent) {
        changeDatePicker(to: .disabled)
        if let newDestination = sender.text {
            destination = newDestination
            sender.resignFirstResponder()
        }
    }
    
    @IBAction func onRepeatTripButtonPressed(_ sender: UIButton) {
        changeDatePicker(to: .disabled)
        repeatTrip = !repeatTrip
        
        switch repeatTrip {
        case true:
            tripRepeatButton.setTitle("Repeat Every Week On", for: .normal)
        case false:
            tripRepeatButton.setTitle("Repeat Every Week Off", for: .normal)
        }
    }
    
    @IBAction func onCreateTripButtonPressed(_ sender: UIButton) {
        
        if destination != "", !kidsOnTrip.isEmpty{
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            let hour = calendar.component(.hour, from: startTime)
            let minute = calendar.component(.minute, from: startTime)
            let seconds = calendar.component(.second, from: startTime)
            
            let components = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: seconds)
            
            let eventTime: Date = components.date!
            
            API.createTrip(eventDescription: destination, eventTime: eventTime, eventLocation: location) { result in
                switch result {
                    
                case .success(let trip):
                    API.set(endTime: self.endTime, for: trip.event)
                    API.mark(trip: trip, repeating: self.repeatTrip)
                    //Don't forget to take the kids
                    break
                case .failure(let error):
                    //TODO Error Handling
                    print(#function, error)
                }
            }
        } else {
            //TODO Error Handling
        }
    }
}

extension AkiCreateTripViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A", for: indexPath)
        return cell
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
    
    var generateSmartDescription: String {
        var kidSubString = "kid name"
        
        if children.count > 0 {
            kidSubString =  children[0].name
        } else if children.count == 2 {
            kidSubString = "\(children[0].name) and \(children[1].name)"
        } else if children.count > 2 {
            kidSubString = "\(children[0].name) and \(children.count - 1) other kids"
        }
        return "On \(event.time.day), \(kidSubString) will be going to: \(event.description) at \(event.time.time)"
    }
}
