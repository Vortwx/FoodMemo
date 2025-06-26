//
//  passSelectedSegue.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 6/5/2024.
//

import UIKit
/**
 - Description: The segue used to pass recipe that user chose in My Recipe Collections back into the page where user adding a new recipe into the plan. The process is AddPlan -> RecipeLibrary -> AddPlan and set up this segue in storyboard is complex and not suitable as it will make it harder to comprehend, hence it is programmatically defined here.
 This part of code cannot be reused in similar situations that involved different viewController.
 
 
 */
class passSelectedSegue: UIStoryboardSegue {
    var recipe: Recipe?
    var itemNquantity: [(String,String)] = []
    
    override func perform() {
        let source = self.source
        guard let navigation = self.destination as? ParentViewController,
              let destination = navigation.viewControllers.first as? PlannerConfigurationViewController else {return}
        guard let recipe = recipe else {return}
        destination.existingRecipe = recipe
        destination.nameTextField.text = recipe.name
        destination.instructionField.text = recipe.instruction
        
        /// extract all the ingredients inside recipe and cast it as Ingredient instead of Any
        guard let ingredients = recipe.ingredientMember else {return}
        let ingredientArray = ingredients.compactMap { $0 as? Ingredient }
        for ingredient in ingredientArray {
            guard let item = ingredient.name, let quantity = ingredient.unit else {return}
            itemNquantity.append((item,quantity))
        }
        /// ingredient table shown in plannerConfiguration screen is embed inside containerView,
        /// access of ingredient table hence is different with usual setup, in this case I stored it as childView property
        /// update function is defined in the childView, we just have to access it here
        destination.childView?.update(existingIngredients: itemNquantity, dynamicTextField: true)
        
        /// jump into the destination screen and pop the extraneous view outside to go back to planerConfiguration screen
        source.view.superview?.addSubview(destination.view)
        destination.view.frame = source.view.frame
        navigation.popViewController(animated: true)
    }
}
