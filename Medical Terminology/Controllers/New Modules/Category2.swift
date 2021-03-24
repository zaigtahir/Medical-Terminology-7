//
//  Category2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/24/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Category2 {
	
	var categoryID = 0
	var name = "none"
	var description = "none"
	var displayOrder = 0
	var isCustom = false
	var count : Int?			//hold count of times in this category, not stored in the db
	
	init() {

	}
	
	convenience init(categoryID: Int, name: String, description: String, displayOrder: Int, isCustom: Bool, count: Int){
		
		self.init()
		
		self.categoryID = categoryID
		self.name = name
		self.description = description
		self.displayOrder = displayOrder
		self.isCustom = isCustom
		self.count = count
		
	}
	
}
