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
            tripDatePicker.datePickerMode = .date
            //switch to time picker
            
        case .disabled:
            tripDatePicker.isHidden = true
            break
        }
    }
    
    @IBAction func onDatePickerValueChanged(_ sender: UIDatePicker) {
        switch selectedButton{
        case .day:
            //update correct button title
            date = sender.date
        case .startTime:
            //update correct button title
            startTime = sender.date
        case .endTime:
            //update correct button title
            endTime = sender.date
        case .disabled:
            break
        }
    }
    
    @IBAction func onDestinationEntered(_ sender: UITextField, forEvent event: UIEvent) {
        if let newDestination = sender.text {
            destination = newDestination
        }
    }
    
    
    @IBAction func onCreateTripButtonPressed(_ sender: UIButton) {
        API.createTrip(eventDescription: destination, eventTime: Date(), eventLocation: location) { result in
            switch result {
                
            case .success(_):
                //Segue to trips
                break
            case .failure(let error):
                //TODO Error Handling
                print(#function, error)
            }
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
        dateFormatter.dateFormat = "hh:aa"
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
