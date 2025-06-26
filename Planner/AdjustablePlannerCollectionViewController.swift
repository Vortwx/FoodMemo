//
//  NonAdjustablePlannerCollectionViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 26/4/2024.
//

import UIKit

private let datePicker = "timeCell"
private let reuseIdentifier = "plannerCell"
private let SECTION_TIME = 0
private let SECTION_PLANNER = 1
var pickerDate: Date?


class AdjustablePlannerCollectionViewController: UICollectionViewController, DatabaseListener{
    
    var listenerType: ListenerType = ListenerType.plan
    
    func onIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        //nothing
    }
    
    func onRecipeIngredientChange(change: DatabaseChange, recipeIngredients: [Ingredient]) {
        //nothing
    }
    
    func onRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        //nothing
    }
    
    func onPlanRecipeChange(change: DatabaseChange, planRecipes: [Recipe], plan:Plan?) {
        //nothing
    }
    
    func onPlanChange(change: DatabaseChange, plan: [Plan]) {
        allPlans = plan
        // need to fetch data at the selected day
        retreiveDayPlan(all: allPlans,selectedDate: pickerDate)
    }
    
    func onCollectionChange(change: DatabaseChange, collections: [Recipe]) {
        //nothing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        pickerDate = sender.date
        retreiveDayPlan(all: allPlans,selectedDate: sender.date)
    }
    
    var allPlans: [Plan] = []
    var currentDayPlans: [Plan] = []
    var currentIndexPath: IndexPath?
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left:0, bottom:0,right:0)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == SECTION_TIME {
            return 1
        } else {
            return currentDayPlans.count
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == SECTION_TIME {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: datePicker, for: indexPath) as? DatePickerCollectionViewCell else{
                fatalError("failed to dequeue")
            }
            pickerDate = cell.embedDatePicker.date
            /// Edge case: Initialisation will call onPlanChange before getting pickerDate thus not filtering Plan
            /// Solution: Filter it everytime cellForRowAt is called
            retreiveDayPlan(all: allPlans,selectedDate: pickerDate)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AdjustablePlannerCollectionViewCell else{
                fatalError("failed to dequeue")
            }
            cell.backgroundColor = .black
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 0.8
            cell.layer.shadowOffset = CGSize(width:10, height: 10)
            cell.layer.shadowColor = UIColor.gray.withAlphaComponent(0.7).cgColor
            cell.configure(with: currentDayPlans[indexPath.row])
            /// update IndexPath so that it is easier to find the plan to be edited
            cell.buttonTappedHandler = {
                [self] in
                currentIndexPath = indexPath
            }
            cell.deleteHandler = {
                [self] in
                databaseController?.deletePlan(plan: currentDayPlans[indexPath.row])
            }
            return cell
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlanSegue" {
            if let destination = segue.destination as? UINavigationController,let configureVC = destination.topViewController as? PlannerConfigurationViewController
            {
                if let index = currentIndexPath{
                    /// it is not feasible to update value directly into the textField as the UI Element hasn't been rendered yet
                    configureVC.existingPlan = currentDayPlans[index.row]
                    configureVC.selectedDate = pickerDate
                }
            }
        } else if segue.identifier == "addPlanSegue"{
            if let destination = segue.destination as? UINavigationController, let configureVC = destination.topViewController as? PlannerConfigurationViewController{
                configureVC.selectedDate = pickerDate
            }
        } else if segue.identifier == "firstInspectionSegue"{
            if let destination = segue.destination as? UINavigationController, let detailVC = destination.topViewController as?
                DetailInspectionViewController{
                if let indexPath = collectionView.indexPathsForSelectedItems, let index = indexPath.first{
                    detailVC.inspectedPlan = currentDayPlans[index.row]
                }
            }
        }
    }

}

extension AdjustablePlannerCollectionViewController{
    /// update plans for selected Date and reload section involved only to prevent infinite loop of reload whole table view
    func retreiveDayPlan(all:[Plan],selectedDate: Date? ){
            currentDayPlans = all.filter{
            guard let time = $0.date else {return false}
            guard let date = selectedDate else {return false}
            return Calendar.current.isDate(time, inSameDayAs: date)
        }
        collectionView.reloadSections(IndexSet(integer: SECTION_PLANNER))
    }
}

extension AdjustablePlannerCollectionViewController: UICollectionViewDelegateFlowLayout{
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Specify different cell sizes for each section
            switch indexPath.section {
            case 0:
                // Return size for section 0
                return CGSize(width: 200, height: 180)
            default:
                // Return default size
                return CGSize(width: 350, height: 100)
            }
        }
}
