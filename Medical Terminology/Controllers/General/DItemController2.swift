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

class DItemController2 {

	/*
	returns the number of favorite terms in this category
	*/
	func getFavoriteCount (category: Category) -> Int {
		
		print ("Implement getFavorite count.. this is in dIC2..so will need to get rid of this anyway")
		
		return 10
	}
	
	/*
	returns the total term count for this category
	*/
	func getAllCount (category: Category) -> Int {
		print ("Implement getAll.. this is in dIC2..so will need to get rid of this anyway")
		
		return 10
	}
	
	
	
	
	func whereString (catetoryType: CategoryType, categoryID: Int,
					  isFavorite: Bool?,
					  answeredTerm: AnsweredState?,
					  answeredDefinition: AnsweredState?,
					  learnedState: Bool?) -> String {
		
		// make favorite string
		var favoriteString = ""
		if let f = isFavorite {
			if f {
				favoriteString = "AND isfavorite = 1"
			} else {
				favoriteString = "AND isfavorite = 0"
			}
		}
		
		// make catetory string
		var categoryString = ""
		
		if catetoryType == .standard && categoryID == 1 {
			categoryString = ""		// intrepred category = a ALL standard categories
		} else {
			categoryString = "AND categoryID = \(categoryID)"
		}
		
		// make answeredTerm string
		var answeredTermString = ""
		if let a = answeredTerm {
			answeredTermString = "AND answeredTerm = \(String(a.rawValue))"
		}
		
		// make answeredDefinition string
		var answeredDefinitionString = ""
		if let d = answeredDefinition {
			answeredDefinitionString = "AND answeredDefinition = \(String(d.rawValue))"
		}
		
		// make learnedString string
		// consider the item learned with both the learnedTerm and learnedDefinition are marked 1
		var learnedString = ""
		if let s = learnedState {
			if s {
				learnedString = "AND (learnedTerm = 1 AND learnedDefinition = 1)"
			}
		}
		
		// assemble the string
		// there will be spaces in the sql for items that are skipped, but that won't matter as that space is ignored by the db
		
		let result = "WHERE itemID >= 0 \(categoryString) \(favoriteString) \(answeredTermString) \(answeredDefinitionString) \(learnedString)"
		
		return result
	}
	
	func getItemIDs (categoryType: CategoryType, whereQuery: String) -> [Int] {
		
		var itemIDs = [Int]()
		
		//make table name
		var table: String

		if categoryType == .standard {
			table = "dictionary"
		} else {
			table = "assignedCategories"
		}
		
		var query = "SELECT itemID FROM \(table) \(whereQuery)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				itemIDs.append(Int(resultSet.int(forColumn: "itemID")))
			}
			
		} else {
			print("fatal error getting resultSet in getItemIDs")
		}
		return itemIDs
	}
	
	func getCount (categoryType: CategoryType, whereQuery: String) -> Int {
		
		//make table name
		var table: String

		if categoryType == .standard {
			table = "dictionary"
		} else {
			table = "assignedCategories"
		}
		
		var query = "SELECT COUNT(*) FROM \(table) \(whereQuery)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return Int( resultSet.int(forColumnIndex: 0) )
		} else {
			return 0
		}
	}
}
