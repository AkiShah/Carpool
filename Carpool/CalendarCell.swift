//
//  CalendarCell.swift
//  Carpool
//
//  Created by Akash Shah on 11/15/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit

class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionWeekdayLabel: UILabel!
    @IBOutlet weak var collectionDateLabel: UILabel!
    @IBOutlet weak var collectionScheduledEventsIndicator: UIView!
    
}

extension RootViewController: UICollectionViewDataSource {
    //This is where all the collectionview magic happens for the calendar
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("I'm being called")
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("I'm being called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Day", for: indexPath) as! CalendarCell
        cell.collectionWeekdayLabel.text = "M"
        cell.collectionDateLabel.text = "10"
        cell.collectionScheduledEventsIndicator.backgroundColor = UIColor.black
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDay = indexPath.item
        trips = getTrips(for: tripSegment(rawValue: TripSegmentedViewController.selectedSegmentIndex)!)
        tableView.reloadData()
    }
    
    
}

