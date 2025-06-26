//
//  IsStringEmpty.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 31/5/2024.
//

import Foundation
func isStringEmpty(_ string:String) -> Bool {
    let targetStr = string.trimmingCharacters(in: .whitespaces)
    return targetStr.isEmpty
}
