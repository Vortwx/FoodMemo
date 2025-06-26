//
//  GroceriesTableViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 5/5/2024.
//

import UIKit
/**
- Description: Ideally the grocery table should be able to combine similar ingredients. However, I faced some techincal difficulties to unify them in current API used
in terms of the unit where it varies from 1 1/2 tsp to Zest of 1. Hence, it is designed to show every ingredient in recipe separately.
*/
class GroceriesTableViewController: UITableViewController{
    let reuseIdentifier = "groceryCell"
    /// listens to all event change except API recipe list change
    /// every change might have impact to grocery table
    var listenerType: ListenerType = ListenerType.all
    
    @IBOutlet weak var timeRangeButton: UIButton!
    
    ///set the time range into today and reload the page to show the ingredients for today only
    private lazy var today = UIAction(title:"Today",attributes:[]){
        action in
        self.timeRange=[Date()]
        self.reloadPage()
    }
    ///set the time range into this week and reload the page to show the ingredients for this week only
    private lazy var thisWeek =
        UIAction(title:"This Week", attributes:[]){
        action in
        var startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
            self.timeRange = []
            for _ in 1...7 {
                guard let date = startOfWeek else {return}
                self.timeRange.append(date)
                startOfWeek = Calendar.current.date(byAdding: .day, value: 1, to: date)
            }
            self.reloadPage()
    }
    
    var groceries: [Ingredient] = []
    var timeRange: [Date] = []
    var allPlans: [Plan] = []
    var currentTimeRangePlan: [Plan] = []
    weak var databaseController: DatabaseProtocol?
    let coreDataController = CoreDataController()
    
    /// button that contains menu with option to choose today or this week, with default value set to today
    func setupTimeRangeButton(){
        timeRangeButton.menu = UIMenu(children:[
            today,thisWeek
        ])
        timeRangeButton.showsMenuAsPrimaryAction = true
        today.state = .on
        timeRange = [Date()]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        setupTimeRangeButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? GroceriesTableViewCell else {fatalError("Failed to dequeue")}
        /// when user click the checkmark it will tick the corresponding row
        cell.checkmarkHandler = {
            [self] in
            coreDataController.checkIngredient(ingredient: groceries[indexPath.row])
            cell.configure(with: groceries[indexPath.row])
        }
        cell.configure(with: groceries[indexPath.row])

        return cell
    }
}

extension GroceriesTableViewController: DatabaseListener{
    func onCollectionChange(change: DatabaseChange, collections: [Recipe]) {
        //nothing
    }
    
    
    func onIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        reloadPage()
    }
    
    func onRecipeIngredientChange(change: DatabaseChange, recipeIngredients: [Ingredient]) {
        reloadPage()
    }
    
    func onRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        reloadPage()
    }
    
    func onPlanRecipeChange(change: DatabaseChange, planRecipes: [Recipe], plan:Plan?) {
        reloadPage()
    }
    
    func onPlanChange(change: DatabaseChange, plan: [Plan]) {
        allPlans = plan
        reloadPage()
    }
    
    /// get the plan within time range
    func retreiveDayPlan(all:[Plan],range: [Date] ){
            currentTimeRangePlan = all.filter{
                var withinRange = false
                guard let time = $0.date else {return false}
                for date in timeRange{
                    if Calendar.current.isDate(time, inSameDayAs: date){
                        withinRange = true
                        break
                    }
                }
                return withinRange
            }
    }
    
    /// delete all the groceries before and repopulate the groceries array by new input
    func reloadPage(){
        groceries.removeAll()
        retreiveDayPlan(all: allPlans, range: timeRange)
        
        for plan in currentTimeRangePlan{
            guard let recipe = plan.recipeMember else {print("Nilrecipe");return}
            guard let ingredients = recipe.ingredientMember else {continue}
            let ingredientsArray = ingredients.compactMap { $0 as? Ingredient }
            groceries.append(contentsOf: ingredientsArray)
        }
        tableView.reloadData()
    }
    
    
}
