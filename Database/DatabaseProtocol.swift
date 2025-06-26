//
//  DatabaseProtocol.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}
/**
 - Description: The listener types contains
 1. Ingredient List Change
 2. Ingredient Change in Recipe
 3. Recipe List Change
 4. Recipe grabbed from API List Change
 5. Recipe Change in Plan
 6. Plan List Change
 7. All Events Stated Above
 */
enum ListenerType {
    case ingredient
    case recipeIngredients
    case recipe
    case collection
    case planRecipes
    case plan
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onIngredientChange(change: DatabaseChange, ingredients:[Ingredient])
    func onRecipeIngredientChange(change: DatabaseChange, recipeIngredients:[Ingredient])
    func onRecipeChange(change: DatabaseChange, recipes:[Recipe])
    func onPlanRecipeChange(change: DatabaseChange, planRecipes:[Recipe], plan:Plan?)
    func onPlanChange(change: DatabaseChange, plan:[Plan])
    func onCollectionChange(change: DatabaseChange, collections:[Recipe])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    //-----------------------------------------------------------------
    // Ingredient
    func addIngredient(measure: Double, name: String, unit: String) -> Ingredient
    func deleteIngredient(ingredient: Ingredient)
    //-----------------------------------------------------------------
    //-----------------------------------------------------------------
    // Recipe
    // method for customised Recipe creation
    func addRecipe(imageURL: String, name: String, instruction: String, videoURL: String) -> Recipe
    // method for API Recipe creation
    func addRecipe(imageURL: String, name: String, instruction: String, videoURL: String,uniqueApiId: String) -> Recipe
    func uncheckRecipeIsCollected(recipe: Recipe)
    func deleteRecipe(recipe: Recipe)
    func updateRecipe(recipe: Recipe, imageURL: String, name: String, instruction: String, videoURL: String) -> Recipe
    func containsRecipe(_ withID: String) -> Recipe?
    //*** Recipe method associated with Ingredient***
    func addIngredientToRecipe(ingredient: Ingredient,recipe: Recipe) -> Bool
    func removeIngredientFromRecipe(ingredient: Ingredient,recipe: Recipe)
    //-----------------------------------------------------------------
    //-----------------------------------------------------------------
    // Plan
    func addPlan(date: Date, eatingTime: Date, mealType: String, note:String, servings: Int32) -> Plan
    func deletePlan(plan: Plan)
    func getCurrentPlan()->Plan?
    func updatePlan(plan: Plan, date: Date, eatingTime: Date, mealType: String, note: String, servings: Int32) -> Plan
    //*** Plan method associated with Recipe***
    func addRecipeToPlan(recipe: Recipe, plan: Plan) -> Bool
    func removeRecipeFromPlan(recipe: Recipe, plan: Plan)
}

