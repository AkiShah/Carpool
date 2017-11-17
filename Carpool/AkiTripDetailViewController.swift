//
//  AkiTripDetailViewController.swift
//  Carpool
//
//  Created by Akash Shah on 11/15/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit
import CarpoolKit
import CoreLocation
import MapKit

class commentCell: UITableViewCell {
    @IBOutlet weak var commentPosterNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
}

class AkiTripDetailViewController: UITableViewController {
    
    //Header
    @IBOutlet weak var eventDestinationLabel: UILabel!
    @IBOutlet weak var eventDestinationAddressButton: UIButton!
    
    //Event Date and Times
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    
    @IBOutlet weak var eventChildrenHeaderLabel: UILabel!
    @IBOutlet weak var eventChildrenLabel: UILabel!
    
    //Drivers Labels and Buttons
    @IBOutlet weak var eventDropoffDriverLabel: UILabel!
    @IBOutlet weak var eventDropoffSubHeader: UILabel!
    @IBOutlet weak var eventDropoffButton: UIButton!
    @IBOutlet weak var eventPickupDriverLabel: UILabel!
    @IBOutlet weak var eventPickupButton: UIButton!
    @IBOutlet weak var eventPickupSubHeader: UILabel!
    
    //Footer
    @IBOutlet weak var eventCommentTextView: UITextView!
    @IBOutlet weak var eventCommentButton: UIButton!
    @IBOutlet weak var eventCommentButtonBottomConstraint: NSLayoutConstraint!
    
    
    var trip: Trip!
    var location: CLPlacemark?
    enum TripLeg {
        case dropoff
        case pickup
    }
    
    enum isLegClaimed {
        case claimed
        case unclaimed
        
        var rawValue: Bool {
            switch self {
            case .claimed:
                return true
            case .unclaimed:
                return false
            }
        }
        init (tripLeg: Leg?) {
            self = tripLeg != nil ? .claimed : .unclaimed
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.observe(trip: trip, sender: self) { result in
            switch result {
            case .success(let trip):
                self.trip = trip
                self.updateTripDetails(using: trip)
                
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Whoops", message: "Couldn't create a new trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
        eventCommentTextView.delegate = self
        eventCommentTextView.text = "Add Comment"
        eventCommentTextView.textColor = UIColor.lightGray
        eventCommentTextView.layer.masksToBounds = true
        eventCommentTextView.layer.cornerRadius = 10
        eventCommentButton.layer.masksToBounds = true
        eventCommentButton.layer.cornerRadius = 10
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: .main) { _ in
            self.eventCommentButtonBottomConstraint.constant = 200
        }
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: .main) { _ in
            self.eventCommentButtonBottomConstraint.constant = 20
        }
    }
    
    
    
    @IBAction func onEventDestinationAddressButtonClicked(_ sender: UIButton) {
        //Go to map
            
        guard let location = location else { return }
            
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance((location.location?.coordinate)!, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: location.location!.coordinate, addressDictionary: location.addressDictionary as! [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = trip.event.description
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func onDropoffButtonClicked(_ sender: UIButton) {
        switch isLegClaimed(tripLeg: trip.dropOff) {
            
        case .claimed:
            API.unclaimDropOff(trip: trip, completion: dropOffClaimChanged)
        case .unclaimed:
            let alert = UIAlertController(title: "Claim this Dropoff", message: "Would you like to claim this dropoff?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Claim Dropoff", style: .default, handler: {_ in
                API.claimDropOff(trip: self.trip, completion: self.dropOffClaimChanged)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPickupButtonPressed(_ sender: UIButton) {
        switch isLegClaimed(tripLeg: trip.pickUp) {
        case .claimed:
            let alert = UIAlertController(title: "Unclaim this Pickup", message: "Would you like to unclaim this pickup?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Unclaim Pickup", style: .default, handler: { _ in
                API.claimPickUp(trip: self.trip, completion: self.pickUpClaimChanged)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .unclaimed:
            let alert = UIAlertController(title: "Claim this Pickup", message: "Would you like to claim this pickup?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Claim Pickup", style: .default, handler: { _ in
                API.claimPickUp(trip: self.trip, completion: self.dropOffClaimChanged)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func dropOffClaimChanged(error: Error?) {
        if let error = error {
            errorMessages(error: error)
        } else {
            print("Look mom, I made a change")
        }
        
    }
    
    func pickUpClaimChanged(error: Error?) {
        if let error = error {
            errorMessages(error: error)
        } else {
            print("Look mom, I made a change")
        }
        
    }
    
    func errorMessages(error: Error) {
        let alert = UIAlertController(title: "Whoops", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'll try again", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onPostCommentButtonClicked(_ sender: UIButton) {
        API.add(comment: eventCommentTextView.text, to: trip)
    }
    
    func updateTripDetails(using trip: Trip) {
    
        eventDestinationLabel.text = trip.event.description
        
        let geocoder = CLGeocoder()
        if let location = trip.event.clLocation {
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first, let subThoroughFare = placemark.subThoroughfare, let throughFare = placemark.thoroughfare, let city = placemark.locality, let state = placemark.administrativeArea, let zip = placemark.postalCode {
                    self.eventDestinationAddressButton.isHidden = false
                    
                    let string = "\(subThoroughFare) \(throughFare)\n\(city) \(state) \(zip)"
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = .center
                    paragraph.lineSpacing = 15
                    let myAttrString = NSAttributedString(string: string, attributes: [
                        .foregroundColor: darkBlue,
                        .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                        .underlineColor: darkOrange,
                        .paragraphStyle: paragraph
                    ])
                    
                    self.eventDestinationAddressButton.setAttributedTitle(myAttrString, for: .normal)
                    self.eventDestinationAddressButton.titleLabel?.numberOfLines = 2
                    self.location = placemark
                    print(subThoroughFare,throughFare, city, state, zip)
                } else {
                    self.eventDestinationAddressButton.isHidden = true
                }
            }
        } else {
            eventDestinationAddressButton.isHidden = true
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM ee"
        eventDateLabel.text = formatter.string(from: trip.event.time)
        formatter.dateFormat = "h : mm"
        eventStartTimeLabel.text = formatter.string(from: trip.event.time)
        eventEndTimeLabel.text = trip.event.endTime != nil ? formatter.string(from: trip.event.endTime!) : "--"
        if !trip.children.isEmpty{
            eventChildrenLabel.text = trip.childrenAsString
            eventChildrenLabel.isHidden = false
            eventChildrenHeaderLabel.isHidden = false
        } else {
            eventChildrenLabel.isHidden = true
            eventChildrenHeaderLabel.isHidden = true
        }
        
        
        updateButtonState(for: .dropoff)
        updateButtonState(for: .pickup)
        tableView.reloadData()
        
    }
    
    func updateButtonState(for leg: TripLeg) {
        let claimStatus = isLegClaimed(tripLeg: leg == .dropoff ? trip.dropOff : trip.pickUp)
        
        switch (leg, claimStatus) {
        case (.dropoff, .claimed):
            let driver = trip.dropOff!.driver
            API.fetchCurrentUser(completion: { result in
                switch result {
                case .success(let user):
                    self.eventDropoffButton.isEnabled = user == driver
                case .failure(let error):
                    let alert = UIAlertController(title: "Whoops", message: "Couldn't unclaim that trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    break
                }
            })
            eventDropoffDriverLabel.text = driver.name
            eventDropoffDriverLabel.textColor = darkBlue
            eventDropoffSubHeader.text = "WILL DROPOFF"
            eventDropoffSubHeader.textColor = darkBlue
            
        case (.dropoff, .unclaimed):
            eventDropoffButton.isEnabled = true
            eventDropoffDriverLabel.text = "UNCLAIMED"
            eventDropoffDriverLabel.textColor = darkOrange
            eventDropoffSubHeader.text = "DROPOFF"
            eventDropoffSubHeader.textColor = darkOrange
            
        case (.pickup, .claimed):
            let driver = trip.pickUp!.driver
            API.fetchCurrentUser(completion: { result in
                switch result {
                case .success(let user):
                    self.eventPickupButton.isEnabled = user == driver
                case .failure(let error):
                    let alert = UIAlertController(title: "Whoops", message: "Couldn't claim that trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    break
                }
            })
            eventPickupDriverLabel.text = driver.name
            eventPickupDriverLabel.textColor = darkBlue
            eventPickupSubHeader.text = "WILL PICKUP"
            eventPickupSubHeader.textColor = darkBlue
            
        case (.pickup, .unclaimed):
            eventPickupButton.isEnabled = true
            eventPickupDriverLabel.text = "UNCLAIMED"
            eventPickupDriverLabel.textColor = darkOrange
            eventPickupSubHeader.text = "PICKUP"
            eventPickupSubHeader.textColor = darkOrange
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath) as! commentCell
        cell.commentLabel.text = trip.comments[indexPath.row].body
        cell.commentLabel.textColor = darkBlue
        cell.commentPosterNameLabel.text = trip.comments[indexPath.row].user.name
        cell.commentPosterNameLabel.textColor = darkBlue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "COMMENTS"
    }
}

extension AkiTripDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = ""
                textView.textColor = darkBlue
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Comment"
            textView.textColor = UIColor.lightGray
        }
    }
}
