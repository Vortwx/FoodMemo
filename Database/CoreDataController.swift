//
//  CoreDataController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//

import UIKit
import CoreData

class CoreDataController: NSObject{
    
    var persistentContainer: NSPersistentContainer
    var listeners = MulticastDelegate<DatabaseListener>()
    var currentRecipe: Recipe?
    var currentPlan: Plan?
    var allIngredientsFetchedResultsController: NSFetchedResultsController<Ingredient>?
    var recipeIngredientsFetchedResultsController: NSFetchedResultsController<Ingredient>?
    var allRecipesFetchedResultsController: NSFetchedResultsController<Recipe>?
    var planRecipesFetchedResultsController:
        NSFetchedResultsController<Recipe>?
    var allPlansFetchedResultsController: NSFetchedResultsController<Plan>?
    var collectionFetchedResultsController: NSFetchedResultsController<Recipe>?
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    
    override init() {
            persistentContainer = NSPersistentContainer(name: "Database")
            
            persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
            } }
            
            super.init()
        }
    
    func fetchAllIngredients() -> [Ingredient]{
        if allIngredientsFetchedResultsController == nil{
            let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            allIngredientsFetchedResultsController = NSFetchedResultsController<Ingredient>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allIngredientsFetchedResultsController?.delegate = self
            do{
                try allIngredientsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let ingredients = allIngredientsFetchedResultsController?.fetchedObjects{
            return ingredients
        }
        return [Ingredient]()
    }
    
    // fetch ingredient in recipes
    func fetchIngredientFromRecipes() -> [Ingredient]{
        var ingredients = [Ingredient]()
        guard let recipe = currentRecipe, let name = recipe.name else {
            return ingredients
        }
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "ANY recipe.id == %@",recipe.id as NSUUID)
        request.sortDescriptors = [nameSortDescriptor]
        request.predicate = predicate
        recipeIngredientsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        recipeIngredientsFetchedResultsController?.delegate = self
        do{
            try recipeIngredientsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        if recipeIngredientsFetchedResultsController != nil {
            ingredients = (recipeIngredientsFetchedResultsController?.fetchedObjects)!
        }
        return ingredients
    }
    
    
    func fetchAllRecipes() -> [Recipe]{
        if allRecipesFetchedResultsController == nil{
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            allRecipesFetchedResultsController = NSFetchedResultsController<Recipe>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allRecipesFetchedResultsController?.delegate = self
            do{
                try allRecipesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let recipes = allRecipesFetchedResultsController?.fetchedObjects{
            return recipes
        }
        return [Recipe]()
    }
    
    // fetch all recipe in plan
    // actually there will be just one recipe in plan
    func fetchRecipeFromPlans() -> [Recipe]{
        var recipes = [Recipe]()
        guard let plan = currentPlan, let date = plan.date else {
            return recipes
        }
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "ANY plan.id == %@",plan.id as NSUUID)
        request.sortDescriptors = [nameSortDescriptor]
        request.predicate = predicate
        planRecipesFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        planRecipesFetchedResultsController?.delegate = self
        do{
            try planRecipesFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        if planRecipesFetchedResultsController != nil {
            recipes = (planRecipesFetchedResultsController?.fetchedObjects)!
        }
        return recipes
    }
    
    func fetchAllPlans() -> [Plan]{
        if allPlansFetchedResultsController == nil{
            let request: NSFetchRequest<Plan> = Plan.fetchRequest()
            let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [dateSortDescriptor]
            
            allPlansFetchedResultsController = NSFetchedResultsController<Plan>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allPlansFetchedResultsController?.delegate = self
            do{
                try allPlansFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let plans = allPlansFetchedResultsController?.fetchedObjects{
            return plans
        }
        return [Plan]()
    }
    
    
    
}

extension CoreDataController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allIngredientsFetchedResultsController{
            listeners.invoke(){
                listener in
                if listener.listenerType == .ingredient || listener.listenerType == .all {
                    listener.onIngredientChange(change: .update, ingredients: fetchAllIngredients())
                }}
        } else if controller == recipeIngredientsFetchedResultsController{
            listeners.invoke(){
                listener in
                if listener.listenerType == .recipeIngredients || listener.listenerType == .all {
                    listener.onRecipeIngredientChange(change: .update, recipeIngredients: fetchIngredientFromRecipes())
                }}
        } else if controller ==
                    allRecipesFetchedResultsController{
            listeners.invoke(){
                listener in
                if listener.listenerType == .recipe || listener.listenerType == .all {
                    listener.onRecipeChange(change: .update, recipes: fetchAllRecipes())
                }}
        } else if controller ==
                    planRecipesFetchedResultsController{
            listeners.invoke(){
                listener in
                if listener.listenerType == .planRecipes || listener.listenerType == .all {
                    listener.onPlanRecipeChange(change: .update, planRecipes: fetchRecipeFromPlans(), plan: getCurrentPlan())
                }}
        } else if controller == allPlansFetchedResultsController{
            listeners.invoke(){
                listener in
                if listener.listenerType == .plan || listener.listenerType == .all {
                    listener.onPlanChange(change: .update, plan: fetchAllPlans())
                }}
        } else if controller == collectionFetchedResultsController{
            listeners.invoke(){
                listener in
                if listener.listenerType == .collection || listener.listenerType == .all {
                    listener.onCollectionChange(change: .update, collections: fetchAPICollections())
                }
            }
        }
    }
    
}
extension CoreDataController: DatabaseProtocol {
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
                    do {
                        try persistentContainer.viewContext.save()
                    } catch {
                        fatalError("Failed to save changes to Core Data with error: \(error)")
                    }
                }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .ingredient || listener.listenerType == .all {
            listener.onIngredientChange(change: .update, ingredients: fetchAllIngredients())
        }
        
        if listener.listenerType == .recipeIngredients || listener.listenerType == .all {
            listener.onRecipeIngredientChange(change: .update, recipeIngredients: fetchIngredientFromRecipes())
        }
        
        if listener.listenerType == .recipe || listener.listenerType == .all {
            listener.onRecipeChange(change: .update, recipes: fetchAllRecipes())
        }
        
        if listener.listenerType == .planRecipes || listener.listenerType == .all {
            listener.onPlanRecipeChange(change: .update, planRecipes: fetchRecipeFromPlans(), plan: getCurrentPlan())
        }
        
        if listener.listenerType == .plan || listener.listenerType == .all {
            listener.onPlanChange(change: .update, plan: fetchAllPlans())
        }
        
        if listener.listenerType == .collection || listener.listenerType == .all {
            listener.onCollectionChange(change: .update, collections: fetchAPICollections())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addIngredient(measure: Double, name: String, unit: String) -> Ingredient {
        let ingredient = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: persistentContainer.viewContext) as! Ingredient
        ingredient.measure = measure
        ingredient.name = name
        ingredient.unit = unit
        ingredient.uniqueID = UUID()
        return ingredient
    }
    
    func deleteIngredient(ingredient: Ingredient) {
        persistentContainer.viewContext.delete(ingredient)
    }
    
    /// check / uncheck the ingredient 
    func checkIngredient(ingredient: Ingredient) {
        ingredient.isChecked = !ingredient.isChecked
        do{
            try persistentContainer.viewContext.save()
        } catch{
            fatalError("Failed to save changes to Core Data")
        }
    }
    
    
    func addRecipe(imageURL: String, name: String, instruction: String, videoURL: String) -> Recipe {
        let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: persistentContainer.viewContext) as! Recipe
        recipe.imageURL = imageURL
        recipe.name = name
        recipe.instruction = instruction
        recipe.videoURL = videoURL
        recipe.isCollected = true
        currentRecipe = recipe
        return recipe
    }
    
    func addRecipe(imageURL: String, name: String, instruction: String, videoURL: String, uniqueApiId: String) -> Recipe {
        let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: persistentContainer.viewContext) as! Recipe
        recipe.imageURL = imageURL
        recipe.name = name
        recipe.instruction = instruction
        recipe.videoURL = videoURL
        recipe.isCollected = true
        recipe.uniqueAPIid = uniqueApiId
        recipe.id = UUID()
        currentRecipe = recipe
        return recipe
    }
    
    func uncheckRecipeIsCollected(recipe: Recipe) {
        /// uncheck the isCollected status
        /// only called when the user doesn't want the collection anymore ( when added it will be updated via configure )
        recipe.isCollected = !recipe.isCollected
        do{
            try persistentContainer.viewContext.save()
        } catch{
            fatalError("Failed to save changes to Core Data")
        }
        /// Tricky implementation of combining logic of not collected recipes will get deleted
        /// Use case of this will be explained in detail in documentation of RecipeLibraryViewController & MyRecipeCollectionsViewController
        deleteRecipe(recipe: recipe)
    }
    
    /// check if this recipe is available already
    func containsRecipe(_ withID: String) -> Recipe? {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "uniqueAPIid == %@", withID)
        do{
            let fetchedRecipes = try persistentContainer.viewContext.fetch(request)
            return fetchedRecipes.first
        } catch {
            return nil
        }
        
    }
    
    func deleteRecipe(recipe: Recipe) {
        persistentContainer.viewContext.delete(recipe)
    }
    
    func addIngredientToRecipe(ingredient: Ingredient, recipe: Recipe) -> Bool {
        recipe.addToIngredientMember(ingredient)
        return true
    }
    
    func removeIngredientFromRecipe(ingredient: Ingredient, recipe: Recipe) {
        recipe.removeFromIngredientMember(ingredient)
    }
    
    func addPlan(date: Date, eatingTime: Date, mealType: String, note: String, servings: Int32) -> Plan {
        let plan = NSEntityDescription.insertNewObject(forEntityName: "Plan", into: persistentContainer.viewContext) as! Plan
        plan.date=date
        plan.eatingTime=eatingTime
        plan.mealType=mealType
        plan.note=note
        plan.servings=servings
        plan.id = UUID()
        currentPlan = plan
        return plan
    }
    
    func deletePlan(plan: Plan) {
        persistentContainer.viewContext.delete(plan)
        appDelegate?.descheduleLocalNotification(plan: plan)
    }
    
    /// return the latest added Plan (which is the current Plan Core Data Controller is managing)
    func getCurrentPlan() -> Plan? {
        guard let plan = currentPlan else {return  nil}
        return plan
    }
    
    /// add the recipe to the plan
    /// also schedule the notification
    /// do this in addPlan function may faced error when the recipe is not added to plan yet
    func addRecipeToPlan(recipe: Recipe, plan: Plan) -> Bool {
        guard plan.recipeMember != nil else{
            recipe.addToPlan(plan)
            appDelegate?.scheduleLocalNotification(plan: plan)
            return true
        }
        /// Cannot add recipe if the plan already contains recipe as this is a 1 to 1 relationship
        return false
    }
    
    /// remove the recipe from the plan
    /// also deschedule the notification
    func removeRecipeFromPlan(recipe: Recipe, plan: Plan) {
        recipe.removeFromPlan(plan)
        appDelegate?.descheduleLocalNotification(plan: plan)
    }
    
    func updateRecipe(recipe: Recipe, imageURL: String, name: String, instruction: String, videoURL: String) -> Recipe {
        var recipeToUpdate: Recipe = recipe
        recipeToUpdate.imageURL = imageURL
        recipeToUpdate.name = name
        recipeToUpdate.instruction = instruction
        recipeToUpdate.videoURL = videoURL
        return recipeToUpdate
    }
    
    func updatePlan(plan: Plan, date: Date, eatingTime: Date, mealType: String, note: String, servings: Int32) -> Plan {
        var planToUpdate: Plan = plan
            planToUpdate.date = date
            planToUpdate.eatingTime = eatingTime
            planToUpdate.mealType = mealType
            planToUpdate.note = note
            planToUpdate.servings = servings
        return planToUpdate
    }
}

extension CoreDataController{
    /// all recipe queried from API contains an ID (named uniqueAPIId, which is different from UUID)
    func fetchAPICollections() -> [Recipe]{
        if collectionFetchedResultsController == nil{
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicate = NSPredicate(format: "uniqueAPIid != nil")
            request.sortDescriptors = [nameSortDescriptor]
            request.predicate = predicate
            
            collectionFetchedResultsController = NSFetchedResultsController<Recipe>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            collectionFetchedResultsController?.delegate = self
            do{
                try collectionFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let collection = collectionFetchedResultsController?.fetchedObjects{
            return collection
        }
        return [Recipe]()
    }
}
