//
//  IsTupleEmpty.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 31/5/2024.
//

import Foundation
func isTupleEmpty (_ tuple: (String,String)) -> Bool{
    return isStringEmpty(tuple.0) || isStringEmpty(tuple.1)
}
