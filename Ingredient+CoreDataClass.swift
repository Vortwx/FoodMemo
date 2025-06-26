//
//  Ingredient+CoreDataClass.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 28/4/2024.
//
//

import Foundation
import CoreData

@objc(Ingredient)
public class Ingredient: NSManagedObject {
    override public var description: String{
        return "Ingredient - Name: \(name ?? ""), Measure: \(measure), Unit: \(unit ?? ""), isChecked: \(isChecked), UUID: \(uniqueID)"
    }
}
