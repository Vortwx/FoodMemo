//
//  DetailInspectionViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 17/5/2024.
//

import UIKit

class DetailInspectionViewController: UIViewController {

    
    @IBOutlet weak var TextViewBackground: UIView!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var instructionField: UITextView!
    
    /// Button that deal with deep linking into Youtube
    @IBAction func watchButtonTapped(_ sender: Any) {
        if let youtubeLink = URL(string: youtubeLink){
            if UIApplication.shared.canOpenURL(youtubeLink) {
                UIApplication.shared.open(youtubeLink, options:[:], completionHandler: nil)
            } else {
                if let safari = URL(string: fallbackLink){
                    externalPrint("Redirect to Safari","To get a better experience it is advised to install Youtube.")
                    UIApplication.shared.open(safari, options:[:], completionHandler: nil)
                }
            }
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    var inspectedPlan: Plan?
    var youtubeLink: String = ""
    var fallbackLink: String = ""
    var childView: EasyIngredientListTableViewController?{
        return children.first {$0 is EasyIngredientListTableViewController} as? EasyIngredientListTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let plan = inspectedPlan, let recipe = plan.recipeMember else {return}
        self.navigationItem.title = recipe.name
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes

        Task {
            await requestImages(model: recipe)
        }

        /// default link given will opened in webpage (safari) while youtubeLink can directly be opened in app
        if let link = recipe.videoURL , let vidID = getYoutubeVideoID(from: link) {
            fallbackLink = link
            youtubeLink = "youtube://\(vidID)"
        }
        
        instructionField.text = recipe.instruction
        instructionField.layer.cornerRadius = 15
        instructionField.layer.borderColor = UIColor.systemGray5.cgColor
        
            
        if let ingredientSet = recipe.ingredientMember{
            var itemNquantity : [String] = []
            var ingredientArray = ingredientSet.compactMap{$0 as? Ingredient}
            for ingredient in ingredientArray {
                guard let item = ingredient.name, let quantity = ingredient.unit else {return}
                itemNquantity.append(quantity + " " + item)
            }
            childView?.update(existingIngredients: itemNquantity)
            }
        
        }
    
    override func viewDidLayoutSubviews(){
        recipeImage?.layer.cornerRadius = 10
        TextViewBackground.layer.cornerRadius = 15
        recipeImage?.clipsToBounds = true
    }

    func requestImages(model: Recipe) async{
            var searchURLComponents = URLComponents()
            let imageLink = model.imageURL
            /// if image link is not valid, set image to default image
            guard let recipeImage = recipeImage else {return}
            guard let url = URL(string: imageLink!) else{
                print("Invalid URL")
                recipeImage.image = UIImage(systemName:"hamburger")
                return
            }
            /// if url components cannot be created, return
            guard var urlComponenets = URLComponents(url: url, resolvingAgainstBaseURL: true) else{
                print("Failed to create URL Components")
                return
            }
            
            urlComponenets.scheme = "https"
            /// if URL cannot be created, return
            guard let requestImageURL = urlComponenets.url else {
                return
            }
            let imageRequest = URLRequest(url: requestImageURL)
            
            do{
                /// fetch image data from URL and convert to UIImage
                let (data, response) = try await URLSession.shared.data(for: imageRequest)
                guard let image=UIImage(data: data) else{
                    print("Invalid image")
                    return
                }
                recipeImage.image = image
            } catch let error{
                    print(error)
            }
            
            
            
        }

}
