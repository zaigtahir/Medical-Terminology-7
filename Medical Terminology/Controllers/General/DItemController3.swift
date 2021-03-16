//
//  DItemController3.swift
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
	
	let tableMain = myConstants.dbTableMain
	let tableUser = myConstants.dbTableUser
	
	func getCount (catetoryID: Int, isFavorite: Bool) -> Int{
		
		let whereQ = whereQuery(categoryID: catetoryID, showOnlyFavorites: .none, isFavorite: isFavorite , answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none)
		
		let query = "SELECT COUNT (*) FROM \(tableString(categoryID: catetoryID)) \(whereQ)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let c = Int(resultSet.int(forColumnIndex: 0))
			return c
		} else {
			print("Fatal error making resultset")
			return 0
		}
		
	}
	
	func getItemIDs (categoryID: Int, showOnlyFavorites: Bool) -> [Int] {
		let whereQ = whereQuery(categoryID: categoryID, showOnlyFavorites: showOnlyFavorites, isFavorite: .none , answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none)
		
		var itemIDs = [Int]()
		let query = "SELECT itemID FROM \(tableString(categoryID: categoryID)) \(whereQ)"
		
		print("getItemIDs query: \(query)")
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				itemIDs.append(Int(resultSet.int(forColumnIndex: 0)))
			}
			return itemIDs
			
		} else {
			print("Fatal error making resultset")
			return itemIDs
		}
		
	}
	
	// MARK: Private functions
	
	private func whereQuery (categoryID: Int, showOnlyFavorites: Bool?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?) -> String {
		
		let categoryString = self.categoryString(categoryID: categoryID)
		
		let showOnlyFavoritesString = self.showOnlyFavoritesString(show: showOnlyFavorites)
		let favoriteString = self.favorteString(isFavorite: isFavorite)
		
		let learnedString = self.learnedString(learned: learned)
		let learnedTermString = self.learnedTermString(learnedTerm: learnedTerm)
		let learnedDefinitionString = self.learnedDefinitionString(learnedDefinition: learnedDefinition)
		
		let answeredTermString = self.answeredTermString(state: answeredTerm)
		let answeredDefinitionString = self.answeredDefinitionString(state: answeredDefinition)
		
		let query = "WHERE \(categoryString) \(favoriteString) \(showOnlyFavoritesString) \(learnedString) \(learnedTermString) \(learnedDefinitionString) \(answeredTermString) \(answeredDefinitionString)"
		
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
	
	private func showOnlyFavoritesString (show: Bool?) -> String {
		var result: String? = ""
		
		if let s = show {
			if s {
				result = "AND isFavorite = 1"
			} else {
				result = ""
			}
		} else {
			result = ""
		}
		
		return result!
	}
	
	// End WHERE string components
}

