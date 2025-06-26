//
//  NonAdjustablePlannerCollectionViewCell.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 26/4/2024.
//

import UIKit

class NonAdjustablePlannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mealTypeLabel: UILabel!
    @IBOutlet weak var mealNameLabel: UILabel!
    
    func configure(with model: Plan){
        guard let recipe = model.recipeMember else{
            return
        }
        mealNameLabel.text = recipe.name
        mealNameLabel.textColor = UIColor.white
        mealTypeLabel.text = model.mealType
        mealTypeLabel.textColor = UIColor.white
    }
}
