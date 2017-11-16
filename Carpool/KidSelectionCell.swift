//
//  KidSelectionCell.swift
//  Carpool
//
//  Created by Akash Shah on 11/16/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit

class KidSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var kidInitialLabel: UILabel!
    @IBOutlet weak var kidNameLabel: UILabel!
    
}

extension AkiCreateTripViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A", for: indexPath) as! KidSelectionCell
        cell.backgroundColor = UIColor.blue
        return cell
    }
}
