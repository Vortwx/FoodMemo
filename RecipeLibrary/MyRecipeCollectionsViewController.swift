//
//  MyRecipeCollectionsViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 22/4/2024.
//

import UIKit
/**
The recipe collection consists of API recipe and custom recipe
When the user wants to remove the recipe from the collection, they just have to uncheck the collected button and this will sync across this page and recipe library
However for the custom recipe it is not possible for user to get back their recipe anymore, thus in this case deletion for custom recipe will be prompted with alert
Note that the navigation from this page to recipe Library inside segue is not available (the transition using passSelectedSegue)
*/
class MyRecipeCollectionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    var data:[Recipe] = []
    var listenerType: ListenerType = ListenerType.recipe
    weak var databaseController: DatabaseProtocol?
    var source: PlannerConfigurationViewController?
    
    /// last row is used to add a cell for adding new recipe
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == data.count {
            guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as? AddCardCollectionViewCell else {
                return UICollectionViewCell()
            }
            /// redirect user to recipe library to choose recipe
            cell.buttonTappedHandler = { [self] in
                tabBarController?.selectedIndex = 1
            }
            return cell
        } else {
            guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? RecipeCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.backgroundColor = UIColor.systemGray5
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.buttonTappedHandler = {
                [self] in
                
                /// Logic to deal with deletion of custom recipe
                /// Custom recipe doesn't have uniqueApiId
                guard let uniqueApiId = data[indexPath.row].uniqueAPIid else {
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive){
                        [self] action in
                        let recipe = data[indexPath.row]
                        if let relatedPlan = recipe.plan, relatedPlan.count != 0{
                            let alertController = UIAlertController(title: "Denied", message: "You have to change the plan that includes current recipe or directly delete the plan.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            present(alertController,animated: true,completion: nil)
                        } else{
                            databaseController?.deleteRecipe(recipe: recipe)
                        }
                    }
                    let alertController = UIAlertController(title: "Delete your recipe", message: "Are you sure you want to delete it? ", preferredStyle: .alert)
                    alertController.addAction(cancelAction)
                    alertController.addAction(deleteAction)
                    present(alertController, animated: true, completion: nil)
                    return
                }
                /// uncheck the selected recipe
                if let duplicate = databaseController?.containsRecipe(uniqueApiId){
                    databaseController?.uncheckRecipeIsCollected(recipe: duplicate)
                }
            }
            cell.configure(with: data[indexPath.row])
            return cell
        }
    }

    @IBOutlet weak var collection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        collection.delegate = self
        collection.dataSource = self
        collection.collectionViewLayout = twoColumnLayout()
        view.addSubview(collection)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    /// layout that split the collection view cell into two columns
    func twoColumnLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.8))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 15, trailing: 10)
                
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
                    
        // Layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    /// setup the size of collectionViewCell so they fit in the columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: size)
        }
    
    /// When select the last cell, redirect into other tab
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collection.cellForItem(at: indexPath) as? AddCardCollectionViewCell{
            tabBarController?.selectedIndex = 1
        }
        
        /// When the cell is selected and it is in the segue from PlannerConfigurationScreen 
        if let cell = collection.cellForItem(at: indexPath) as? RecipeCollectionViewCell, let parent = source{
            let selected = data[indexPath.row]
            guard let dest = parent.parent as? ParentViewController else {return}
            let segue = passSelectedSegue(identifier: nil, source: self, destination: dest)
            segue.recipe = selected
            segue.perform()
        }
    }
    
    

}

extension MyRecipeCollectionsViewController: DatabaseListener {
    
    //This is only part of all the collected recipes
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
        data = recipes
        collection.reloadData()
    }
    
    func onPlanRecipeChange(change: DatabaseChange, planRecipes: [Recipe], plan:Plan?) {
        //nothing
    }
    
    func onPlanChange(change: DatabaseChange, plan: [Plan]) {
        //nothing
    }
    
    
}
