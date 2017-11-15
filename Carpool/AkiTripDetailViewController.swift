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

class AkiTripDetailViewController: UITableViewController {
    
    //Header
    @IBOutlet weak var eventDestinationLabel: UILabel!
    @IBOutlet weak var eventDestinationAddressButton: UIButton!
    
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    
    @IBOutlet weak var theChildrenLabel: UILabel!
    @IBOutlet weak var eventDropoffDriverLabel: UILabel!
    @IBOutlet weak var eventPickupDriverLabel: UILabel!
    
    //Footer
    @IBOutlet weak var eventCommentTextView: UITextView!
    
    
    
    
    var trip: Trip!
    let comments: [Comment] = []
    
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
        
        eventDestinationLabel.text = trip.event.description
        eventDateLabel.text = ""
        eventStartTimeLabel.text = ""
        eventEndTimeLabel.text = ""
        
        //updateButtonState(for: .dropoff)
        //updateButtonState(for: .pickup)
        
        API.observe(trip: trip, sender: self) { result in
            switch result {
            case .success(let trip):
                self.trip = trip
                //self.updateButtonState(for: .dropoff)
                //self.updateButtonState(for: .pickup)
                
                let geocoder = CLGeocoder()
                if let location = trip.event.clLocation {
                    geocoder.reverseGeocodeLocation(location) { placemarks, error in
                        if let state = placemarks?.first?.administrativeArea, let city = placemarks?.first?.locality{
                            //self.eventLocationLabel.text = "\(city), \(state)"
                        } else if let error = error {
                            //self.errorMessages(error: error)
                        }
                    }
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "h : mm"
                //self.eventTimeLabel.text = formatter.string(from: trip.event.time)
                
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Whoops", message: "Couldn't create a new trip. \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Thanks, I'll try again", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    @IBAction func onEventDestinationAddressButtonClicked(_ sender: UIButton) {
        //Go to map
        
    }
    
    @IBAction func onPostCommentButtonClicked(_ sender: UIButton) {
        //Post comment
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        return cell
    }
    
}
