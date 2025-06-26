//
//  EasyIngredientListTableViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 31/5/2024.
//

import UIKit

class EasyIngredientListTableViewController: UITableViewController {
    
    var ingredientsListing : [String] = []
    let reuseIdentifier = "listingCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsListing.count
    }
    
    func update(existingIngredients: [String]){
        ingredientsListing = existingIngredients
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = ingredientsListing[indexPath.row]
        return cell
    }

}
