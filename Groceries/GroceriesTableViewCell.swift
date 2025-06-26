//
//  GroceriesTableViewCell.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 5/5/2024.
//

import UIKit

class GroceriesTableViewCell: UITableViewCell {

    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmark: UIButton!
    var checkmarkHandler: (()-> Void)?
    
    @IBAction func checkmarkTapped(_ sender: Any) {
        isChecked = !isChecked
        /// let ViewController define this checkmarkHandler method and invoke when checkmark is tapped
        checkmarkHandler?()
    }
    
    /// isChecked variable will dynamically listen to variable change and respond according to that
    var isChecked: Bool = false {
        didSet{
            if isChecked{
                checkmark.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.systemBlue),for: .normal)
            } else{
                checkmark.setImage(UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// setup the cell with relevant information
    func configure (with model: Ingredient){
        nameLabel.text = model.name
        guard let unit = model.unit else {return}
        measureLabel.text = unit
        isChecked = model.isChecked
    }
    

}
