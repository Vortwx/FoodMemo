//
//  RecipeData.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//

import UIKit

class RecipeData: NSObject, Decodable{
    var id: String?
    var name: String?
    var instructions: String?
    var imageURL: String?
    var videoURL: String?
    var ingredients: [String?] = []
    var measures: [String?] = []
    var collected: Bool = false
    
    
    private enum RecipeKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case instructions = "strInstructions"
        case imageURL = "strMealThumb"
        case videoURL = "strYoutube"
        case ingredient1 = "strIngredient1"
        case ingredient2 = "strIngredient2"
        case ingredient3 = "strIngredient3"
        case ingredient4 = "strIngredient4"
        case ingredient5 = "strIngredient5"
        case ingredient6 = "strIngredient6"
        case ingredient7 = "strIngredient7"
        case ingredient8 = "strIngredient8"
        case ingredient9 = "strIngredient9"
        case ingredient10 = "strIngredient10"
        case ingredient11 = "strIngredient11"
        case ingredient12 = "strIngredient12"
        case ingredient13 = "strIngredient13"
        case ingredient14 = "strIngredient14"
        case ingredient15 = "strIngredient15"
        case ingredient16 = "strIngredient16"
        case ingredient17 = "strIngredient17"
        case ingredient18 = "strIngredient18"
        case ingredient19 = "strIngredient19"
        case ingredient20 = "strIngredient20"
        case measure1 = "strMeasure1"
        case measure2 = "strMeasure2"
        case measure3 = "strMeasure3"
        case measure4 = "strMeasure4"
        case measure5 = "strMeasure5"
        case measure6 = "strMeasure6"
        case measure7 = "strMeasure7"
        case measure8 = "strMeasure8"
        case measure9 = "strMeasure9"
        case measure10 = "strMeasure10"
        case measure11 = "strMeasure11"
        case measure12 = "strMeasure12"
        case measure13 = "strMeasure13"
        case measure14 = "strMeasure14"
        case measure15 = "strMeasure15"
        case measure16 = "strMeasure16"
        case measure17 = "strMeasure17"
        case measure18 = "strMeasure18"
        case measure19 = "strMeasure19"
        case measure20 = "strMeasure20"
        /// method for finding the ingredient key for a given index
        static func ingredientCase(forIndex index: Int) -> RecipeKeys? {
                return RecipeKeys(rawValue: "strIngredient\(index)")
            }
        /// method for finding the measure key for a given index
        static func measureCase(forIndex index: Int) -> RecipeKeys? {
                return RecipeKeys(rawValue: "strMeasure\(index)")
            }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecipeKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        videoURL = try container.decodeIfPresent(String.self, forKey: .videoURL)
        for i in 1...20{
            guard let ingredientKey = RecipeKeys.ingredientCase(forIndex: i) else {super.init();return}
            guard let measureKey = RecipeKeys.measureCase(forIndex: i) else {super.init();return}
            if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey), ingredient.isEmpty == false,
               let measure = try container.decodeIfPresent(String.self, forKey: measureKey), measure.isEmpty == false
            {
                ingredients.append(ingredient)
                measures.append(measure)
            }
            else {break}
        }
        super.init()
    }
}
