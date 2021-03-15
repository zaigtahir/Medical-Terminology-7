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
	
	func whereQuery (categoryID: Int,
					 isFavorite: Bool?,
					 answeredTerm: AnsweredState?,
					 answeredDefinition: AnsweredState?,
					 learned: Bool?,
					 learnedTerm: Bool?,
					 learnedDefinition: Bool?) -> String {
		
		let tableString = self.tableString(categoryID: categoryID)
		let categoryString = self.categoryString(categoryID: categoryID)
		let favoriteString = self.favorteString(isFavorite: isFavorite)
		
		let learnedString = self.learnedString(learned: learned)
		let learnedTermString = self.learnedTermString(learnedTerm: learnedTerm)
		let learnedDefinitionString = self.learnedDefinitionString(learnedDefinition: learnedDefinition)
		
		let answeredTermString = self.answeredTermString(state: answeredTerm)
		let answeredDefinitionString = self.answeredDefinitionString(state: answeredDefinition)
		
		let query = "SELECT COUNT (*) FROM \(tableString) WHERE \(categoryString) \(favoriteString) \(learnedString) \(learnedTermString) \(learnedDefinitionString) \(answeredTermString) \(answeredDefinitionString)"
		
		return query
	}
	
	// MARK: WHERE string components
	
	private func tableString (categoryID: Int) -> String {
		var table: String
		if categoryID < 1000 {
			table = tableMain
		} else {
			table = tableUser
		}
		return table
	}
	
	private func favorteString (isFavorite: Bool?) -> String {
		
		// note i had to set the favoriteString as optional and then at the end send it as forced unwrap value because
		// if the favorite string is formed in the if-let statement, it is optional when it comes out of those conditions
		
		var result: String? = ""
		
		if let f = isFavorite {
			if f {
				result = "AND isfavorite = 1"
			} else {
				result = "AND isfavorite = 0"
			}
		}
		return result!
	}
	
	private func categoryString (categoryID: Int?) -> String {
		//make category string
		
		var result: String? = ""
		
		if let i = categoryID {
			
			if i == 0 {
				result =  "(categoryID >= 1 AND categoryID <1000)"
			} else {
				result = "categoryID = \(i)"
			}
		}
		return result!
	}
	
	private func learnedString (learned: Bool?) -> String {
		
		// make learnedString string
		// consider the item learned with both the learnedTerm and learnedDefinition are marked 1
		
		var result: String? = ""
		
		if let s = learned {
			if s {
				result = "AND (learnedTerm = 1 AND learnedDefinition = 1)"
			}
			else {
				result = "AND (learnedTerm = 0 OR learnedDefinition = 0)"
			}
		}
		return result!
	}
	
	private func learnedTermString (learnedTerm: Bool?) -> String {
		
		// make learnedString string
		
		var result: String? = ""
		
		if let s = learnedTerm {
			if s {
				result = "AND learnedTerm = 1"
			}
			else {
				result = "AND learnedTerm = 0"
			}
		}
		return result!
	}
	
	private func learnedDefinitionString (learnedDefinition: Bool?) -> String {
		
		// make learnedString string
		
		var result: String? = ""
		
		if let s = learnedDefinition {
			if s {
				result = "AND learnedDefinition = 1"
			}
			else {
				result = "AND learnedDefinition = 0"
			}
		}
		
		return result!
	}
	
	private func answeredTermString (state: AnsweredState?) -> String {
		
		// make learnedString string
		// consider the item learned with both the learnedTerm and learnedDefinition are marked 1
		
		var result: String? = ""
		
		if let s = state {
			result = "AND answeredTerm = \(s.rawValue)"
		}
		return result!
	}
	
	private func answeredDefinitionString (state: AnsweredState?) -> String {
		
		// make learnedString string
		// consider the item learned with both the learnedTerm and learnedDefinition are marked 1
		
		var result: String? = ""
		
		if let s = state {
			result = "AND answeredDefinition = \(s.rawValue)"
		}
		return result!
	}
	
}

