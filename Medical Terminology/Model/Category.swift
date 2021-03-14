//
//  Category.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit


class Category {
    
    var categoryID = 0
    var name = "none"
    var description = "none"
	var type = CategoryType.standard
    var displayOrder = 0
	var selected = false
    
    // just reminder never use category with ID 999 as it's just a placeholder in the database
    // for ordering the standard categories, use 1 onward.
	
	init() {

	}
	
	convenience init(categoryID: Int, name: String, description: String, type: CategoryType, displayOrder: Int, selected: Bool){
		
		self.init()
		
		self.categoryID = categoryID
        self.name = name
        self.description = description
        self.type = type
        self.displayOrder = displayOrder
		self.selected = selected
		
    }
    
}
