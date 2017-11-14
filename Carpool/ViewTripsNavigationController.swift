//
//  RootNavigationController.swift
//  Carpool
//
//  Created by Zaller on 11/9/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CarpoolKit

class ViewTripsNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(forName: loginNotification, object: nil, queue: .main) { _ in
            if let loginVC = self.presentedViewController as? LoginViewController {
                loginVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if API.isCurrentUserAnonymous {
            let loginVC = storyboard!.instantiateViewController(withIdentifier: "LoginVC")
            present(loginVC, animated: animated, completion: nil)
        } else {
            NotificationCenter.default.post(name: loginNotification, object: nil)
        }
    }
}
