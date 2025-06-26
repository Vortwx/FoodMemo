//
//  RecipeCollectionViewCell.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 21/4/2024.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var images: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var collectButton: UIButton!
    var buttonTappedHandler: (() -> Void)?
    
    /// listen to variable change and respond accordingly
    var isCollected: Bool = false {
        didSet{
            if isCollected{
                collectButton.setImage(UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.systemRed),for: .normal)
            } else{
                collectButton.setImage(UIImage(systemName: "heart.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label), for: .normal)
            }
        }
    }
    
    @IBAction func collectButtonTapped(_ sender: UIButton) {
        buttonTappedHandler?()
    }
    
    public func configure(with model: RecipeData) {
        recipeName.text = model.name
        isCollected = model.collected
        Task{
            await requestImages(model: model)
        }
    }
    
    func requestImages(model: RecipeData) async{
            var searchURLComponents = URLComponents()
            var imageLink = model.imageURL
            /// if image link is not valid, set image to default image
            guard let url = URL(string: imageLink!) else{
                print("Invalid URL")
                images.image = UIImage(systemName:"hamburger")
                return
            }
            /// if URL components cannot be created, return
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
                images.image = image
            } catch let error{
                    print(error)
            }
            
            
            
        }

}
// extension for Recipe Core Data in MyCollectionViewController
extension RecipeCollectionViewCell {
    public func configure(with model: Recipe) {
        recipeName.text = model.name
        isCollected = model.isCollected
        Task{
            await requestImages(model: model)
        }
    }
    
    func requestImages(model: Recipe) async{
            var searchURLComponents = URLComponents()
            var imageLink = model.imageURL
            /// if image link is not valid, set image to default image
            guard let url = URL(string: imageLink!) else{
                images.image = UIImage(systemName:"hamburger")
                return
            }
            /// if URL components cannot be created, return
            guard var urlComponenets = URLComponents(url: url, resolvingAgainstBaseURL: true) else{
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
                    return
                }
                images.image = image
            } catch let error{
                    print(error)
            }
            
            
            
        }
}
