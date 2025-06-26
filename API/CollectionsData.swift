//
//  CollectionsData.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//

import UIKit

class CollectionsData: NSObject,Decodable {
    var recipes:[RecipeData]?
    
    private enum CodingKeys: String, CodingKey {
        case recipes = "meals"
    }
}
