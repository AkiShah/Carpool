//
//  KidSelectionCell.swift
//  Carpool
//
//  Created by Akash Shah on 11/16/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import Foundation
import UIKit
import CarpoolKit

class KidSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var kidInitialLabel: UILabel!
    @IBOutlet weak var kidNameLabel: UILabel!
    
}

extension AkiCreateTripViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(kidsOnTrip)
        return kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A", for: indexPath) as! KidSelectionCell
        let kid = kids[indexPath.row]
        if kidsOnTrip.contains(kid) {
            cell.kidInitialLabel.backgroundColor = lightOrange
        } else {
            cell.kidInitialLabel.backgroundColor = darkBlue
        }
        cell.kidInitialLabel.text = kid.name.substring(to: kid.name.index(kid.name.startIndex, offsetBy: 2))
        cell.kidInitialLabel.layer.masksToBounds = true
        //cell.kidInitialLabel.layer.cornerRadius = 22
        cell.kidNameLabel.text = kid.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = kidsOnTrip.index(of: kids[indexPath.row]) {
            kidsOnTrip.remove(at: index)
        } else {
            kidsOnTrip.append(kids[indexPath.row])
        }

        collectionView.reloadData()
    }
    
    
}

extension Child: Equatable {
    public static func == (lhs: Child, rhs: Child) -> Bool {
        return lhs.name == rhs.name
    }
}

