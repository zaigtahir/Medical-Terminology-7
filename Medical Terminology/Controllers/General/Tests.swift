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
		dIC3.getTermCount(categoryID: 0, isFavorite: true, learned: false)
		dIC3.getTermCount(categoryID: 1002, isFavorite: .none, learned: .none)
		dIC3.getTermCount(categoryID: 10, isFavorite: true, learned: true)
	}
}
