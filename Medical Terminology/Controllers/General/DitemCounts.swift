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

class DItemCounts {

	func whereString (categoryID: Int?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learnedState: Bool?) -> String {
		
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
		if let c = categoryID {
			categoryString = "AND categoryID = \(c)"
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
	
	private func getCount (query: String) -> Int {
				
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return Int(resultSet.int(forColumnIndex: 0))
		} else {
			print("problem creating the resultSet in getCount")
			return 0
		}
	}
}
