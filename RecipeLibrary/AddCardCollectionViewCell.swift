//
//  AddCardCollectionViewCell.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 22/4/2024.
//

import UIKit

class AddCardCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var addButton: UIButton!
    var buttonTappedHandler: (() -> Void)?
    
    @IBAction func addButtonTapped(_ sender: Any) {
        buttonTappedHandler?()
    }
}
