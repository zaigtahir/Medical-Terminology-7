//
//  DItemController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/12/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

//this class if for getting counts of DItems

/*
categoryID = 0: all standard categories, table = mainTerms
categoryID = 1-998: just that catetory, table = mainTerms
categoryID = 999: just a place holder
categoryID = >= 1000: jus that category, table = userCategoryTerms
*/

class DItemController3 {

	let tableMain = "dictionary"
	let tableUser = "assignedCategories"
	
	/*
	returns the number of favorite terms in this category
	*/
	
	
	func getTermCount (categoryID: Int) -> Int {
		
		var table: String
		if categoryID < 1000 {
			table = tableMain
		} else {
			table = tableUser
		}
		
		//make category string
		var categoryString: String
		
		if categoryID == 0 {
			categoryString = "(categoryID >= 1 AND categoryID <1000)"
		} else {
			categoryString = "categoryID = \(categoryID)"
		}
		
		let query = "SELECT COUNT (*) FROM \(table) WHERE \(categoryString)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return Int(resultSet.int(forColumnIndex: 0))
		} else {
			return 0
		}
	}
	
}
