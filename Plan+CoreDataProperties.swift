//
//  Plan+CoreDataProperties.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//
//

import Foundation
import CoreData

enum MealType: String, CaseIterable{
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    
    var time: (hour:Int, minute: Int){
        switch self {
        case .breakfast:
            return (9,0)
        case .lunch:
            return (12,0)
        case .dinner:
            return (19,0)
        }
    }
}

extension Plan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plan> {
        return NSFetchRequest<Plan>(entityName: "Plan")
    }

    @NSManaged public var eatingTime: Date?
    @NSManaged public var mealType: String?
    @NSManaged public var note: String?
    @NSManaged public var servings: Int32
    @NSManaged public var date: Date?
    @NSManaged public var recipeMember: Recipe?
    @NSManaged public var id: UUID

}

extension Plan : Identifiable {

}
