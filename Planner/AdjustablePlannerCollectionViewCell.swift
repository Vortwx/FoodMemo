//
//  PlannerCollectionViewCell.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 23/4/2024.
//

import UIKit

class AdjustablePlannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deletePlannerButton: UIButton!
    @IBOutlet weak var editPlannerButton: UIButton!
    @IBOutlet weak var mealTypeLabel: UILabel!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBAction func editButtonTapped(_ sender: Any) {
        buttonTappedHandler?()
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteHandler?()
    }
    var currentPlan: Plan?
    var buttonTappedHandler: (() -> Void)?
    var deleteHandler: (() -> Void)?
    
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
