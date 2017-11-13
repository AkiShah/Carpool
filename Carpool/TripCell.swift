//
//  TripCell.swift
//  Carpool
//
//  Created by Zaller on 11/7/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit


class TripCell: UITableViewCell {
    
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var dropoffLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var tripDetailInfoButton: UIButton!
    @IBOutlet weak var dropoffCarBlue: UIImageView!
    @IBOutlet weak var pickupCarPink: UIImageView!
    @IBOutlet weak var kidNames: UILabel!
    
}
