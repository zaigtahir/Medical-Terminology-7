//
//  Category.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Category {
    
    var categoryID: Int
    var name: String
    var description: String
    var displayOrder: Int
    
    // just reminder never use category with ID 999 as it's just a placeholder in the database
    // for ordering the standard categories, use 1 onward.
    
    var type: CategoryType {
        get {
            if categoryID < 999 {
                return .standard
            } else {
                return .custom
            }
        }
    }
    
    init(categoryID: Int, name: String, description: String, displayOrder: Int){
        self.categoryID = categoryID
        self.name = name
        self.description = description
        self.displayOrder = displayOrder
    }
    
}
