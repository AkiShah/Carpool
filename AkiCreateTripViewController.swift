//
//  AkiCreateTripViewController.swift
//  
//
//  Created by Akash Shah on 11/16/17.
//

import Foundation
import UIKit


class AkiCreateTripViewController: UIViewController {
    
    var destination: String = ""
    //Location
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
    
    func changeDatePicker(to newSelection: DayOrTime) {
        switch newSelection {
        case day:
            //switch to day picker
            break
        case startTime, endTime:
            break
            //switch to time picker
        case disabled:
            //hide datepicker
            break
        }
    }
    
    func saveDatetTo() {
        switch selectedButton{
        case day:
            //update correct button title
            date = Date()
        case startTime:
            //update correct button title
            startTime = Date()
        case endTime:
            //update correct button title
            endTime = Date()
        case disabled:
            break
        }
    }
    
}
