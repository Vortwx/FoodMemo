//
//  Recipe+CoreDataProperties.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 31/5/2024.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: UUID
    @NSManaged public var imageURL: String?
    @NSManaged public var instruction: String?
    @NSManaged public var isCollected: Bool
    @NSManaged public var name: String?
    /// uniqueAPIid is used to identify the recipe from the API
    @NSManaged public var uniqueAPIid: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var ingredientMember: NSSet?
    @NSManaged public var plan: NSSet?

}

// MARK: Generated accessors for ingredientMember
extension Recipe {

    @objc(addIngredientMemberObject:)
    @NSManaged public func addToIngredientMember(_ value: Ingredient)

    @objc(removeIngredientMemberObject:)
    @NSManaged public func removeFromIngredientMember(_ value: Ingredient)

    @objc(addIngredientMember:)
    @NSManaged public func addToIngredientMember(_ values: NSSet)

    @objc(removeIngredientMember:)
    @NSManaged public func removeFromIngredientMember(_ values: NSSet)

}

// MARK: Generated accessors for plan
extension Recipe {

    @objc(addPlanObject:)
    @NSManaged public func addToPlan(_ value: Plan)

    @objc(removePlanObject:)
    @NSManaged public func removeFromPlan(_ value: Plan)

    @objc(addPlan:)
    @NSManaged public func addToPlan(_ values: NSSet)

    @objc(removePlan:)
    @NSManaged public func removeFromPlan(_ values: NSSet)

}

extension Recipe : Identifiable {

}
