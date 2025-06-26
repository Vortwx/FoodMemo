//
//  Test.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 24/4/2024.
//

import UIKit

private let reuseIdentifier = "plannerCell"

class NonAdjustablePlannerCollectionViewController: UICollectionViewController, DatabaseListener{
    
    var listenerType: ListenerType = ListenerType.plan
    
    func onCollectionChange(change: DatabaseChange, collections: [Recipe]) {
        //nothing
    }
    
    func onIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        //nothing
    }
    
    func onRecipeIngredientChange(change: DatabaseChange, recipeIngredients: [Ingredient]) {
        //nothing
    }
    
    func onRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        //nothing
    }
    
    func onPlanRecipeChange(change: DatabaseChange, planRecipes: [Recipe], plan: Plan?) {
        //nothing
    }
    
    func onPlanChange(change: DatabaseChange, plan: [Plan]) {
        allPlans = plan
        retreiveDayPlan(all: allPlans, selectedDate: selectedDate)
    }
    
    var currentDayPlans: [Plan] = []
    var allPlans: [Plan] = []
    var selectedDate: Date?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:350, height:120)
        layout.sectionInset = UIEdgeInsets(top:10, left:5, bottom:10,right:5)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
    }

    // MARK: UICollectionViewDataSource
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDayPlans.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? NonAdjustablePlannerCollectionViewCell else {
            fatalError("Failed to dequeue")
        }
        cell.backgroundColor = UIColor.black
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.configure(with: currentDayPlans[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return collectionView.frame.size.height
    }
    
    /// segue to DetailInspectionScreen with navigationBar preserved
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secondInspectionSegue"{
            if let destination = segue.destination as? UINavigationController, let detailVC = destination.topViewController as? DetailInspectionViewController{
                if let indexPath = collectionView.indexPathsForSelectedItems, let index = indexPath.first{
                    detailVC.inspectedPlan = currentDayPlans[index.row]
                }
            }
        }
    }


}
extension NonAdjustablePlannerCollectionViewController{
    /// update the selected date and retrieve the plans for that date
    func update(withDate: Date?){
        selectedDate = withDate
        retreiveDayPlan(all: allPlans, selectedDate: selectedDate)
    }
    
    func retreiveDayPlan(all:[Plan],selectedDate: Date? ){
            currentDayPlans = all.filter{
            guard let time = $0.date else {return false}
            guard let date = selectedDate else {return false}
            return Calendar.current.isDate(time, inSameDayAs: date)
        }
        collectionView.reloadData()
    }
}
