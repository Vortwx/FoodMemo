//
//  PlannerConfigurationViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 24/4/2024.
//

import UIKit

class PlannerConfigurationViewController: UIViewController{
    /**

    The logic of add Plan and edit Plan is fused into one function
    There are several scenarios:
    1. Add plan from scratch
    - A new recipe will become visible in My Recipe Collections screen

    2. Add plan from My Recipe Collections (It is designed so that user will not be flooded by same recipe everytime they create a new plan)
    - No new recipe will be added
    - Change made (ingredients) will be sync to the original recipe in My Recipe Collections screen

    3. Edit plan
    - No new recipe will be added
    - Only action happen is update
    - Change made (ingredients) will be sync to the original recipe in My Recipe Collections screen

    */
    @IBAction func saveButtonTapped(_ sender: Any) {
        var recipe: Recipe?
        var plan: Plan?
        var instruction = ""
        var name = ""
        var listOfIngredients : [(String,String)] = []
        var servings = Int32(1)
        
        /// Breakfast will be selected as default value
        guard let type = mealType else {return}
        
        /// Error Checking Section Start
        
        if let inputServings = servingNumberField.text, !isStringEmpty(inputServings){
            if let inputServings = Int32(inputServings){
                if inputServings <= 0{
                    externalPrint("Invalid serving input", "Servings should be at least 1")
                    return
                }
                servings = inputServings
            }
            else{
                externalPrint("Invalid serving input", "Input value is not Integer")
                return
            }
        }
        else {
            externalPrint("Invalid plan", "Missing servings")
            return
        }
    
        
        if let inputListOfIngredients = childView?.ingredients, inputListOfIngredients.count > 0 {
            for ingredient in inputListOfIngredients {
                if isTupleEmpty(ingredient){
                    externalPrint("Invalid ingredient", "Ingredient must have both item and quantity stated")
                    return
                }
            }
            listOfIngredients = inputListOfIngredients
        }
        else {
            externalPrint("Invalid plan", "Plan must have at least 1 ingredient")
            return
        }
        
        
        if let inputName = nameTextField.text, !inputName.isEmpty{
            name = inputName
        }
        else {
            externalPrint("Invalid plan", "Plan must have name")
            return
        }
        
        if let inputInstruction = instructionField.text {
            instruction = inputInstruction
        }
        
        /// Error Checking Section End
        
        /// Case when you add plan from scratch
        if existingRecipe == nil {
            recipe = databaseController?.addRecipe(imageURL: "", name: name, instruction: instruction, videoURL: "")
        } else{
            if let existingPlan = existingPlan, let previousRecipe = prevRecipe {
                /// Useful in scenario 3 where user need to edit the plan
                /// First remove the old recipe from the current plan
                let _ = databaseController?.removeRecipeFromPlan(recipe: previousRecipe, plan: existingPlan)
            }
            guard let existingRecipe = existingRecipe else {return}
            /// update existingRecipe so that it is now point to the new recipe user just modified
            recipe = databaseController?.updateRecipe(recipe: existingRecipe, imageURL: existingRecipe.imageURL ?? "", name: name, instruction: instruction, videoURL: existingRecipe.videoURL ?? "")
            
            
        }
        guard let recipe = recipe else {return}
        /// There exist a problem that the previous added ingredient will become duplicate if we choose to add again all ingredients below
        /// However, we need to add again all ingredients as there might be edit OR addition to original ingredients
        /// We cope with this by delete the original ingredients and add whatever currently available in listOfIngredients
        if let duplicate = recipe.ingredientMember {
            let duplicateArray = duplicate.compactMap { $0 as? Ingredient }
            for originalIngredient in duplicateArray{
                let _ = databaseController?.removeIngredientFromRecipe(ingredient: originalIngredient, recipe: recipe)
                let _ = databaseController?.deleteIngredient(ingredient: originalIngredient)
            }
        }
        /// Now we should have a recipe with Nil ingredients list
        
        for ingredient in listOfIngredients {
            let item =  databaseController?.addIngredient(measure: 1, name: ingredient.0, unit: ingredient.1)
            guard let item = item else {return}
            let _ = databaseController?.addIngredientToRecipe(ingredient: item, recipe: recipe)
        }
        /// After recipe is properly setup, record it as prevRecipe 
        /// Checking of existingPlan will prevent prevRecipe being utilised when called by addPlan button
        prevRecipe = recipe
        guard let planDate = selectedDate else {return}
        guard let mealTime = setTime(date: planDate, hour: type.time.hour, min: type.time.minute) else {print("Time is not valid");return}
        
        /// Check if there is any existing Plan
        if existingPlan == nil{
            plan =
            databaseController?.addPlan(date: planDate, eatingTime: mealTime, mealType: type.rawValue, note: "Nothing", servings: servings)
        } else{
            /// Scenario where plan needs to be updated
            guard let existingPlan = existingPlan else {return}
            plan = databaseController?.updatePlan(plan: existingPlan, date: planDate, eatingTime: mealTime, mealType: type.rawValue, note: existingPlan.note ?? "Nothing", servings: servings)
        }
        
 
        guard let plan = plan else {print("Error");return}
        let _ = databaseController?.addRecipeToPlan(recipe: recipe, plan: plan)
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var mealTypeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var instructionField: UITextView!
    @IBOutlet weak var servingNumberField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ingredientTable: UITableView!
    weak var databaseController: DatabaseProtocol?
    var existingPlan: Plan?
    var selectedDate: Date?
    var mealType: MealType?
    /// User's current recipe
    var existingRecipe: Recipe?
    /// Recipe in plan before user change
    var prevRecipe: Recipe?
    /// childView is the view embedded in ContainerView
    var childView: IngredientTableViewController?{
        return children.first {$0 is IngredientTableViewController} as? IngredientTableViewController
    }
    var childViewInitializer: [(String,String)] = []
    
    /// UIActions for menu with default value of first mealType (in this case breakfast)
    var mealTypeActions: [UIAction] {
        var temp: [UIAction] = []
        for (index,mealType) in MealType.allCases.enumerated(){

            if index == 0 {
                temp.append(UIAction(title: mealType.rawValue, state: .on){
                    (action: UIAction) in
                    self.updateMealType(mealtype: action.title)
                    self.selectedChildrenIndex = index
                })
            } else {
                temp.append(UIAction(title: mealType.rawValue){
                    (action: UIAction) in
                    self.updateMealType(mealtype: action.title)
                    self.selectedChildrenIndex = index
                })
            }
        }
        return temp
    }
    
    var selectedChildrenIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height+300)
        
        /// setup menu and menu choosing logic
        mealTypeButton.menu = UIMenu(children: mealTypeActions)
        mealTypeButton.showsMenuAsPrimaryAction = true
        mealTypeButton.changesSelectionAsPrimaryAction = true
        if let buttonString = mealTypeButton.menu?.selectedElements.first?.title {
            updateMealType(mealtype: buttonString)
        }
        
        (mealTypeButton.menu?.children[selectedChildrenIndex] as? UIAction)?.state = .on
        
        
        
        /// Only edit button has detail about existingPlan
        /// Place to setup for editing plan
        if let curr = existingPlan, let currentRecipe = curr.recipeMember{
            prevRecipe = currentRecipe
            existingRecipe = currentRecipe
            /// They are set to reference to same object instead of copying
            /// This is because I need to keep them without duplicate in My Recipe Collection
            /// This is functional because the change I did on prevRecipe is simply detach it from the original Plan
            /// which doesn't affect the data inside

            if let name = currentRecipe.name{
                nameTextField.text = name
            }
            if let instruction = currentRecipe.instruction{
                instructionField.text = instruction
            }
            servingNumberField.text = String(curr.servings)
            if let mealType = curr.mealType{
                /// to reset the actions selected a new list for UIActions must be created
                var updatedMealTypeActions = mealTypeActions
                updatedMealTypeActions[0] = UIAction(title: updatedMealTypeActions[0].title) { action in
                    self.updateMealType(mealtype: action.title)
                    self.selectedChildrenIndex = 0
                }
                for (index,meal) in updatedMealTypeActions.enumerated() {
                    if mealType == meal.title{
                        updatedMealTypeActions[index].state = .on
                        mealTypeButton.menu = UIMenu(children: updatedMealTypeActions)
                        updateMealType(mealtype: updatedMealTypeActions[index].title)
                        break
                    }
                }
            }
            
            if let ingredientSet = currentRecipe.ingredientMember{
                var itemNquantity : [(String,String)] = []
                var ingredientArray = ingredientSet.compactMap{$0 as? Ingredient}
                for ingredient in ingredientArray {
                    guard let item = ingredient.name, let quantity = ingredient.unit else {return}
                    itemNquantity.append((item,quantity))
                }
                childView?.update(existingIngredients: itemNquantity, dynamicTextField: true)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFromSegue"{
            if let child = segue.destination as? MyRecipeCollectionsViewController{
                child.source = self
            }
        }
    }
    
    
    

}

extension PlannerConfigurationViewController {
    func setTime(date:Date,hour:Int,min:Int) -> Date? {
        guard hour <= 24, min < 60 else {print("Incorrect time format");return nil}
        //00 means start of today, 24 means end of today
        var calendar =  Calendar.current
        calendar.locale = Locale.current
        var components = DateComponents()
        components.hour = hour
        components.minute = min
        guard let hour = components.hour, let min = components.minute else {print("Unwrap failed");return nil}
        return calendar.date(bySettingHour: hour, minute: min, second: 0, of: date)
    }
    
    func updateMealType(mealtype: String){
        mealType = MealType(rawValue: mealtype)
        
    }
}

