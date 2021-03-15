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
	
	let cc2 = CategoryController()
	let dIC3 = DItemController3()
	
	func test () {
		print (dIC3.getTermCount(categoryID: 0))
		print (dIC3.getTermCount(categoryID: 3))
		print (dIC3.getTermCount(categoryID: 1006))
	}
}
