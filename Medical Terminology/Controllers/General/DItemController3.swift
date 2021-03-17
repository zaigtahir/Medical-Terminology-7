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
	

	func getCount (catetoryID: Int, isFavorite: Bool?) -> Int{
		
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
	
	func getDItems (whereQuery: String)  -> [DItem] {
		
		// return an array of DItems based on the whereClause
		// if nothing found return an empty array
		
		// displayTerm will be selected instead of term for the item.term if there is something in the displayTerm
		// so when you retrieve the data or sort by names, user "term" field as it does not have the preceding "-"
				
		let query = "SELECT * from dictionary \(whereQuery)"
		
		var dItems = [DItem]()
		
		if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
			
			while resultSet.next() {
				
				let itemID = Int(resultSet.int(forColumn: "itemID"))
				var term = resultSet.string(forColumn: "term") ?? ""
				let termDisplay = resultSet.string(forColumn: "termDisplay") ?? ""
				let definition = resultSet.string(forColumn: "definition")  ?? ""
				let example = resultSet.string(forColumn: "example")  ?? ""
				let categoryID = Int(resultSet.int(forColumn: "categoryID"))
				let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
				let f = Int(resultSet.int(forColumn: "isFavorite"))
				let t = Int(resultSet.int(forColumn: "learnedTerm"))
				let d = Int(resultSet.int(forColumn: "learnedDefinition"))
				let answeredTerm = Int(resultSet.int(forColumn: "answeredTerm"))
				let answeredDefintion = Int(resultSet.int(forColumn: "answeredDefinition"))
				
				var isFavorite: Bool = false
				var learnedTerm: Bool = false
				var learnedDefinition: Bool = false
				
				if f != 0 {
					isFavorite = true
				}
				
				if t != 0 {
					learnedTerm = true
				}
				
				if d != 0 {
					learnedDefinition = true
				}
				
				//replace term with termDisplay if there is something in term display
				if termDisplay.isEmpty == false {
					term = termDisplay
				}
				
				let item = DItem(itemID: itemID,
								 term: term,
								 definition: definition,
								 example: example,
								 categoryID: categoryID,
								 audioFile: audioFile,
								 isFavorite: isFavorite,
								 learnedTerm: learnedTerm,
								 learnedDefinition: learnedDefinition,
								 answeredTerm: answeredTerm,
								 answeredDefinition: answeredDefintion)
				
				dItems.append(item)
			}
		}
		return dItems
	}
  
	func getDItem (itemID: Int) -> DItem {
				
		let dItems = getDItems(whereQuery: " WHERE itemID = \(itemID) ")
		
		if dItems.count == 0 {
			
			print("DItemController: getDItem: ERROR!!! could not find dItem with itemID: \(itemID). Returning a default dItem")
			
			return DItem()
			
		} else {
			
			return dItems[0]
		}
	}
	
	func toggleIsFavorite (itemID: Int) {
		let item = getDItem(itemID: itemID)
		saveIsFavorite(itemID: itemID, isFavorite: !item.isFavorite)
	}
	
	func saveIsFavorite (itemID: Int, isFavorite: Bool) {
		
		var favoriteState = 0
		if isFavorite {
			favoriteState = 1
		}
		
		myDB.executeUpdate("UPDATE dictionary SET isFavorite = ? where itemID = ?", withArgumentsIn: [favoriteState, itemID])
		
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

