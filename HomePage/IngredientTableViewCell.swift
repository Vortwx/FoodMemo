//
//  IngredientTableViewCell.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 9/5/2024.
//

import UIKit

protocol UpdateInputDelegate: AnyObject {
    func setup(_ cell: IngredientTableViewCell,didEndEditingItem item: String?, quantity:String?)
}

class IngredientTableViewCell: UITableViewCell, UITextFieldDelegate{

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var itemField: UITextField!
    weak var delegate: UpdateInputDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemField.delegate = self
        quantityField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with data: (String,String)){
        itemField.text = data.0
        quantityField.text = data.1
    }
    
    func setup() -> (String,String){
        guard let item = itemField.text, let quantity = quantityField.text else {
            fatalError("Cannot Unwrap")
        }
        return (item, quantity)
    }
    
    /// this is use instead of textFieldDidEndEditing
    /// as TextFieldDidEndEditing requires explicit return key which may miss some information
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.setup(self, didEndEditingItem: itemField.text, quantity: quantityField.text)
    }

}
