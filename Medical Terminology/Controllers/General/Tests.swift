//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	
	//test category2 Controller
	
	let cc2 = CategoryController2()
	
	func test () {
		var c = cc2.getCurrentCategory()
		print ("current category name: \(c.name)")
		
		print("toggling to category ID 3")
		cc2.toggleCategorySelection(categoryID: 8)
		
		c = cc2.getCurrentCategory()
		print ("current category name: \(c.name)")
		
		print("adding a custom catetory")
		
		cc2.addCustomCategory(name: "Susan")
		cc2.addCustomCategory(name: "Jackie")
	}
}
