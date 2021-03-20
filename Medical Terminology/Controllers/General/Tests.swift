//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	
	func sectionCategoryTests () {
		let cc = CategoryController()
		
		print ("categoryID for flashcards: \(cc.getSectionCategoryID(sectionName: .flashcards))")
		cc.setSectionCategoryID(sectionName: .flashcards, categoryID: 0)
		print ("categoryID for flashcards: \(cc.getSectionCategoryID(sectionName: .flashcards))")
	}
	
}
