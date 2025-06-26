//
//  TwoColumnViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 21/4/2024.
//

import UIKit
// DatabaseListener for APIRecipe Change, doesnt concern about other
/**
It is found that this API doesn't support pagination, hence to get all possible results we must retreive all recipes in API and manually filter 
it according to searchText.
This might bring serious burden to application as this is done on business logic.
After considering the tradeoff such as the difficulty of implementation, time for implementation and responding speed of application
I decided not to do any kind of de facto pagination and only use what I have queried in one query as result
*/
class RecipeLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
 
    var indicator = UIActivityIndicatorView()
    weak var databaseController: DatabaseProtocol?
    let coreDataController = CoreDataController()
    let REQUEST_STRING = "https://www.themealdb.com/api/json/v1/1/search.php?s="
    @IBOutlet weak var collection: UICollectionView!
    var searchedRecipes: [RecipeData] = []
    var measure: [String?] = []
    var listenerType: ListenerType = ListenerType.collection
    var APIcollections: [Recipe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        collection.collectionViewLayout = twoColumnLayout()
        view.addSubview(collection)
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find recipe"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        collection.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
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

    /// set the size of each cell to be half of the screen width
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: size)
        }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedRecipes.count
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? RecipeCollectionViewCell else {
            fatalError("Failed to dequeue")
        }
            cell.backgroundColor = UIColor.systemGray5
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            /// add recipe into core data when collected
            cell.buttonTappedHandler = { 
                [self] in
                
                guard let imageURL = searchedRecipes[indexPath.row].imageURL else {return}
                guard let name = searchedRecipes[indexPath.row].name else {return}
                guard let instruction = searchedRecipes[indexPath.row].instructions else {return}
                guard let videoURL = searchedRecipes[indexPath.row].videoURL else {return}
                guard let uniqueApiId = searchedRecipes[indexPath.row].id else {return}

                if let duplicate = databaseController?.containsRecipe(uniqueApiId){
                    databaseController?.uncheckRecipeIsCollected(recipe: duplicate)
                } else {
                    let recipe = databaseController?.addRecipe(imageURL: imageURL, name: name, instruction: instruction, videoURL: videoURL, uniqueApiId: uniqueApiId)
                    for i in 0...19{
                        if i == searchedRecipes[indexPath.row].ingredients.count{
                            cell.configure(with: searchedRecipes[indexPath.row])
                            collectionView.reloadData()
                            return
                        }
                        guard let ingredient = searchedRecipes[indexPath.row].ingredients[i] else {return}
                        guard let measure = searchedRecipes[indexPath.row].measures[i] else {return}
                        //hardcode measure as 1 now as all ingredient use name instead of dividing measure into numbers and unit
                        let oneIngredient = databaseController?.addIngredient(measure: 1, name: ingredient, unit: measure)
                        guard let ingredient = oneIngredient, let recipe = recipe else{return}
                        let _ = databaseController?.addIngredientToRecipe(ingredient: ingredient, recipe: recipe)
                    }
                }
            }
            cell.configure(with: searchedRecipes[indexPath.row])
            return cell
        }
    
    func requestRecipesNamed(_ recipeName: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.themealdb.com"
        searchURLComponents.path = "/api/json/v1/1/search.php"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "s", value: recipeName)]
        
        guard let requestURL = searchURLComponents.url else {
                print("Invalid URL")
                return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do{
            let (data,response) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            let recipe = try decoder.decode(CollectionsData.self, from: data)
            if let recipe = recipe.recipes{
                searchedRecipes.append(contentsOf: recipe)
            }
            indicator.stopAnimating()
            collection.reloadData()
            /// update the recipe shown to collected 
            /// this is because the status of collected can vanish after reload due to the recipe shown are RecipeData instead of part of core data
            /// they are not synchronous to whatever change we have done hence need to make them catch up in this function
            recollectRecipeOn(list: searchedRecipes, collections: APIcollections)
        } catch let error {
            externalPrint("Error","Something has gone wrong here")
            indicator.stopAnimating()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        searchedRecipes.removeAll()
        collection.reloadData()
        guard let searchText = searchBar.text else{
            return
        }
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        URLSession.shared.invalidateAndCancel()
        Task{
            await requestRecipesNamed(searchText)
        }
    }

}

extension RecipeLibraryViewController{
    func recollectRecipeOn(list: [RecipeData],collections:[Recipe]){
        ///collect all recipe with unique API
        var APIids: [String] = []
        for collection in collections {
            guard let id = collection.uniqueAPIid else {return}
            APIids.append(id)
        }
        //if I find the API recipe existence in My Recipe Collections also we know that it needs to be marked collected
        for data in list{
            guard let id = data.id else {return}
            if APIids.contains(id){
                data.collected = true
            } else{
                data.collected = false
            }
        }
    }
}

extension RecipeLibraryViewController: DatabaseListener{
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
        //nothing
    }
    
    func onCollectionChange(change: DatabaseChange, collections: [Recipe]) {
        APIcollections = collections
        recollectRecipeOn(list: searchedRecipes, collections: APIcollections)
        collection.reloadData()
    }
    
    
}

