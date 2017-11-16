//
//  HomeScreenViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    @IBOutlet weak var viewTripsButton: UIButton!
    @IBOutlet weak var addATripButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTripsButton.backgroundColor = UIColor.init(red: 0.29, green: 0.31, blue: 0.40, alpha: 1.0)
        addATripButton.backgroundColor = UIColor.init(red: 0.91, green: 0.76, blue: 0.51, alpha: 1.0)
        
        
    }
}
