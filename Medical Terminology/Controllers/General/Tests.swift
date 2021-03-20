//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	
	func testGettingItemIDs (){
		let dItem = DItem()
		dItem.categoryID = 12
		
		let catC = CategoryController()
		let defaultCat = catC.getItemDefaultCategoryID(itemID: 12)
		print ("\(defaultCat)")
		
		let ids = catC.getItemCustomCategoryIDs(itemID: 12)
		
	}
	
}
