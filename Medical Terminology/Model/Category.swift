//
//  Category2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/24/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Category {
	
	var categoryID = -1
	var name = ""
	var description = ""
	var displayOrder = 0
	var isStandard = false
	var division = -1
	var count = 0				//hold count of times in this category, not stored in the db, and I will need to calculate the latest value when needed
	
	init() {

	}
	
	convenience init(categoryID: Int, name: String, description: String, displayOrder: Int, isStandard: Bool, division: Int, count: Int){
		
		self.init()
		
		self.categoryID = categoryID
		self.name = name
		self.description = description
		self.displayOrder = displayOrder
		self.isStandard = isStandard
		self.division = division
		self.count = count
		
	}
	
}
