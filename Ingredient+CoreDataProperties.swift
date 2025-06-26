//
//  Ingredient+CoreDataProperties.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var measure: Double
    @NSManaged public var name: String?
    @NSManaged public var unit: String?
    @NSManaged public var recipe: NSSet?
    @NSManaged public var isChecked: Bool
    @NSManaged public var uniqueID: UUID

}

// MARK: Generated accessors for recipe
extension Ingredient {

    @objc(addRecipeObject:)
    @NSManaged public func addToRecipe(_ value: Recipe)

    @objc(removeRecipeObject:)
    @NSManaged public func removeFromRecipe(_ value: Recipe)

    @objc(addRecipe:)
    @NSManaged public func addToRecipe(_ values: NSSet)

    @objc(removeRecipe:)
    @NSManaged public func removeFromRecipe(_ values: NSSet)

}

extension Ingredient : Identifiable {

}

