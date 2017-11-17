//
//  CalendarCell.swift
//  Carpool
//
//  Created by Akash Shah on 11/15/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit

class CalendarCollectionViewHeaderView: UICollectionReusableView {
    @IBOutlet weak var calendarHeader: UILabel!
}


class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionWeekdayLabel: UILabel!
    @IBOutlet weak var collectionDateLabel: UILabel!
    @IBOutlet weak var collectionScheduledEventsIndicator: UIView!
    
}

extension RootViewController: UICollectionViewDataSource {
    //This is where all the collectionview magic happens for the calendar

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Day", for: indexPath) as! CalendarCell
        
        let today = Calendar.current.startOfDay(for: Date())
        let daysFromToday = today + TimeInterval(indexPath.row * 60 * 60 * 24)
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        cell.collectionWeekdayLabel.text = formatter.string(from: daysFromToday)
        formatter.dateFormat = "d"
        cell.collectionDateLabel.text = formatter.string(from: daysFromToday)
        cell.collectionScheduledEventsIndicator.layer.masksToBounds = true
        cell.collectionScheduledEventsIndicator.layer.cornerRadius = 5
        
        if tripsForDays[indexPath.row].isEmpty{
            cell.collectionScheduledEventsIndicator.isHidden = true
        } else {
            cell.collectionScheduledEventsIndicator.isHidden = false
        }
        
        switch selectedDay == indexPath.row {
        case true:
            cell.backgroundColor = darkBlue
            cell.collectionScheduledEventsIndicator.backgroundColor = lightOrange
            cell.collectionDateLabel.textColor = lightOrange
            cell.collectionWeekdayLabel.textColor = lightOrange
        case false:
            cell.backgroundColor = lightOrange
            cell.collectionScheduledEventsIndicator.backgroundColor = darkBlue
            cell.collectionDateLabel.textColor = darkBlue
            cell.collectionWeekdayLabel.textColor = darkBlue
        }
       
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDay = indexPath.item
        calendarCollectionView.reloadData()
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "A", for: indexPath) as! CalendarCollectionViewHeaderView
                let today = Calendar.current.startOfDay(for: Date())
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                headerView.calendarHeader.text = formatter.string(from: today)
                return headerView
            default:
            assert(false, "Unexpected element kind")
        }
    }
    
    
}

