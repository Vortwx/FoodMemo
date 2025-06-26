//
//  IngredientTableViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 9/5/2024.
//

import UIKit

class IngredientTableViewController: UITableViewController,UpdateInputDelegate{
    
    func setup(_ cell: IngredientTableViewCell, didEndEditingItem item: String?, quantity: String?) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        if let item = item, let quantity = quantity{
            ingredients[indexPath.row] = (item,quantity)
        }
    }
    
    
    
    var ingredients:[(String,String)] = []
    var identifier = "ingredientCell"
    var isEditable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// show ingredients except for the last row
        if indexPath.row < ingredients.count {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? IngredientTableViewCell else {
                fatalError("Cell dequeued failed")
            }
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.layer.shadowRadius = 5
            cell.delegate = self /// Set the delegate
            cell.itemField.text = ingredients[indexPath.row].0
            cell.itemField.isUserInteractionEnabled = isEditable
            cell.quantityField.text = ingredients[indexPath.row].1
            cell.quantityField.isUserInteractionEnabled = isEditable
            cell.countLabel.text = String(indexPath.row + 1) + "."
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addMoreCell", for: indexPath) as? AddMoreTableViewCell else {
                fatalError("Cell dequeued failed")
            }
            cell.isUserInteractionEnabled = isEditable
            if cell.isUserInteractionEnabled{
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    
    
    /// We can only edit the row that show ingredients and if it is editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == ingredients.count || !isEditable{
             return false
         } else {
             return true
         }
     }
     
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.row != ingredients.count && isEditable{
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
        
    /// When user tap the last cell of the tableView a new space is available for input
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.row == ingredients.count && isEditable{
                ingredients.append(("",""))
                tableView.reloadData()
            }
        }
    }
    
extension IngredientTableViewController{
    func update(existingIngredients: [(String,String)], dynamicTextField: Bool){
        ingredients = existingIngredients
        isEditable = dynamicTextField
        tableView.reloadData()
    }
}
