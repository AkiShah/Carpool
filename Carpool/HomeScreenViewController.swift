//
//  HomeScreenViewController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class HomeScreenViewController: UIViewController {
    @IBOutlet weak var viewTripsButton: UIButton!
    @IBOutlet weak var addATripButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTripsButton.backgroundColor = oliveGray
        viewTripsButton.layer.borderWidth = 2
        viewTripsButton.layer.borderColor = UIColor.init(red: 0.29, green: 0.31, blue: 0.40, alpha: 1.0).cgColor
        addATripButton.backgroundColor = UIColor.init(red: 0.91, green: 0.76, blue: 0.51, alpha: 1.0)
        addATripButton.layer.borderWidth = 2
        addATripButton.layer.borderColor = UIColor.init(red: 0.29, green: 0.31, blue: 0.40, alpha: 1.0).cgColor
        
        API.fetchCurrentUser(completion: { result in
            switch result {
                
            case .success(let user):
                self.userNameLabel.text = user.name
            case .failure(let error):
                print(#function, error)
            }
        })
        
        
        
    }
}



//extension UIButton
//{
//    func roundCorners(corners:UIRectCorner, radius: CGFloat)
//    {
//        let borderLayer = CAShapeLayer()
//        borderLayer.frame = self.layer.bounds
//        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: CGFloat(corners.rawValue))
//        borderLayer.path = path.cgPath
//        self.layer.addSublayer(borderLayer);
//    }
//}

