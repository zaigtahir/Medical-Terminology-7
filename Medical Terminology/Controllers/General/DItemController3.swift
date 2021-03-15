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
	
	func getTermCount (categoryID: Int, isFavorite: Bool?) {
		
		let tableString = self.tableString(categoryID: categoryID)
		let categoryString = self.categoryString(categoryID: categoryID)
		let favoriteString = self.favorteString(isFavorite: isFavorite)
		
		let query = "SELECT COUNT (*) FROM \(tableString) WHERE \(categoryString) \(favoriteString)"
		
		print (query)
	}
	
	// MARK: WHERE string components
	
	func tableString (categoryID: Int) -> String {
		var table: String
		if categoryID < 1000 {
			table = tableMain
		} else {
			table = tableUser
		}
		return table
	}
	
	func favorteString (isFavorite: Bool?) -> String {
		
		// note i had to set the favoriteString as optional and then at the end send it as forced unwrap value because
		// if the favorite string is formed in the if-let statement, it is optional when it comes out of those conditions
		
		var favoriteString: String? = ""
		
		if let f = isFavorite {
			if f {
				favoriteString = "AND isfavorite = 1"
			} else {
				favoriteString = "AND isfavorite = 0"
			}
		}
		return favoriteString!
	}
	
	func categoryString (categoryID: Int?) -> String {
		//make category string
	
		var categoryString: String? = ""
		
		if let i = categoryID {
			
			if i == 0 {
				categoryString =  "(categoryID >= 1 AND categoryID <1000)"
			} else {
				categoryString = "categoryID = \(i)"
			}
		}
		return categoryString!
	}
	
	
}
