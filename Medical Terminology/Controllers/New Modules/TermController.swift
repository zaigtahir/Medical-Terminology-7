//
//  TermController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/23/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

/*
Query example for removing the leading prefix
SELECT *, replace(name,’-’,’’) as partForSortingHyphen
FROM terms
ORDER BY partForSortingHyphen ASC
*/

/*
Query example

SELECT terms.termID
FROM terms
JOIN  assignCategories2 ON terms.termID = assignCategories2.termID
WHERE assignCategories2.categoryID = 3
*/

class TermController {
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	func getTerm (termID: Int) -> Term {
		
		let query = "SELECT * FROM \(myConstants.dbTableTerms) WHERE termID = \(termID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return makeTerm(resultSet: resultSet)
		} else {
			print("fatal error could not make result set or get term in getTerm")
			return Term()
		}
	}
	
	func getTermIDs (categoryID: Int, showFavoritesOnly: Bool?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?, nameContains: String?, nameStartsWith: String?, orderByName: Bool?) -> [Int]{
		
		let selectStatement = "SELECT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName FROM \(terms) JOIN \(assignedCategories) ON \(terms).termID = \(assignedCategories).termID "
		
		let whereStatement = self.whereStatement (categoryID: categoryID,
												 showOnlyFavorites: showFavoritesOnly,
												 isFavorite: isFavorite,
												 answeredTerm: answeredTerm,
												 answeredDefinition: answeredDefinition,
												 learned: learned,
												 learnedTerm: learnedTerm,
												 learnedDefinition: learnedDefinition,
												 learnedFlashcard: learnedFlashcard,
												 nameContains: nameContains,
												 nameStartsWith: nameStartsWith,
												 orderByName: orderByName)
		
		let query = ("\(selectStatement) \(whereStatement)")
		
		print("query in getTermIDs: \(query)")
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
				
			}
		}
		return ids
	}

	func getCount (categoryID: Int, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?, nameContains: String?, nameStartsWith: String?) -> Int {
		
		// will remove leading hypen for count purposes
		
		let selectStatement = "SELECT COUNT (*) FROM \(terms) JOIN \(assignedCategories) ON \(terms).termID = \(assignedCategories).termID "
		
		let whereStatement = self.whereStatement(categoryID: categoryID,
												 showOnlyFavorites: .none,
												 isFavorite: isFavorite,
												 answeredTerm: answeredTerm,
												 answeredDefinition: answeredDefinition,
												 learned: learned,
												 learnedTerm: learnedTerm,
												 learnedDefinition: learnedDefinition,
												 learnedFlashcard: learnedFlashcard,
												 nameContains: nameContains,
												 nameStartsWith: nameStartsWith,
												 orderByName: .none)
		
		let query = ("\(selectStatement) \(whereStatement)")
		
		print("query in get count: \(query)")
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		}
		
		return count
		
	}
	
	func setFavoriteStatusPostNotification (categoryID: Int, termID: Int, isFavorite: Bool) {
		let query = "UPDATE \(myConstants.dbTableAssignedCategories) SET isFavorite = \( isFavorite ? 1 : 0 ) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		_ = myDB.executeStatements(query)
		
		// fire off notification that a terms information changed
		
		let data = ["categoryID" : categoryID, "termID" : termID]
		
		let name = Notification.Name(myKeys.termInformationChangedNotification)
		NotificationCenter.default.post(name: name, object: self, userInfo: data)
	}
	
	func getFavoriteStatus ( categoryID: Int, termID: Int ) -> Bool {
		let query = "SELECT isFavorite FROM \(assignedCategories) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let status = Int(resultSet.int(forColumnIndex: 0))
			return status == 1 ?  true : false
		} else {
			print ("fatal error getting resultSet in getFavoriteStatus, returning false")
			return false
		}
	}

	func getTermCategoryIDs ( termID: Int) -> [Int] {
		
		var ids = [Int]()
		
		let query = "SELECT categoryID FROM \(myConstants.dbTableAssignedCategories) WHERE termID = \(termID)"
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		} else {
			print ("fatal error getting result set in getTermCategoryIDs")
		}
		
		return ids
		
	}
	
	private func makeTerm (resultSet: FMResultSet) -> Term {
		
		let termID = Int(resultSet.int(forColumn: "termID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let definition = resultSet.string(forColumn: "definition")  ?? ""
		let example = resultSet.string(forColumn: "example")  ?? ""
		let secondCategoryID = Int(resultSet.int(forColumn: "secondCategoryID"))
		let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
		let s = Int(resultSet.int(forColumn: "isStandard"))
		
		let term = Term(termID: termID, name: name, definition: definition, example: example, secondCategoryID: secondCategoryID, audioFile: audioFile, isStandard: s == 1)
		
		return term
	}
	
	private func whereStatement (categoryID: Int, showOnlyFavorites: Bool?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?, nameContains: String?, nameStartsWith: String?, orderByName: Bool?) -> String {
		
		let showOnlyFavoritesString = self.showOnlyFavoritesString(show: showOnlyFavorites)
		
		let favoriteString = self.favorteString(isFavorite: isFavorite)
		
		let learnedString = self.learnedString(learned: learned)
		let learnedTermString = self.learnedTermString(learnedTerm: learnedTerm)
		let learnedDefinitionString = self.learnedDefinitionString(learnedDefinition: learnedDefinition)
		
		let answeredTermString = self.answeredTermString(state: answeredTerm)
		let answeredDefinitionString = self.answeredDefinitionString(state: answeredDefinition)
		
		let learnedFlashcardString = self.learnedFlashcardString(learned: learnedFlashcard)
		
		let nameContainsString = self.nameContainsString(search: nameContains)
		
		let nameStartsWithString = self.nameStartsWithString(search: nameStartsWith)
		
		let orderByNameString = self.orderByNameString(toOrder: orderByName)
		
		// need to add ORDER BY
		
		let whereStatement = "WHERE \(assignedCategories).categoryID = \(categoryID) \(favoriteString) \(showOnlyFavoritesString) \(learnedString) \(learnedTermString) \(learnedDefinitionString) \(answeredTermString) \(answeredDefinitionString) \(learnedFlashcardString ) \(nameContainsString) \(nameStartsWithString) \(orderByNameString)"
		
		return whereStatement
	}
	
	// MARK: WHERE string components
	
	private func favorteString (isFavorite: Bool?) -> String {
		guard let f = isFavorite else { return "" }
		return f ? "AND isfavorite = 1" : "AND isfavorite = 0"
	}
	
	private func learnedString (learned: Bool?) -> String {
		guard let l = learned else { return "" }
		return l ? "AND (learnedTerm = 1 AND learnedDefinition = 1)" : "AND (learnedTerm = 0 OR learnedDefinition = 0)"
	}
	
	private func learnedTermString (learnedTerm: Bool?) -> String {
		guard let lt = learnedTerm else { return ""}
		return lt ? "AND learnedTerm = 1" : "AND learnedTerm = 0"
	}
	
	private func learnedDefinitionString (learnedDefinition: Bool?) -> String {
		guard let ld = learnedDefinition else { return ""}
		return ld ? "AND learnedDefinition = 1" : "AND learnedDefinition = 0"
	}
	
	private func answeredTermString (state: AnsweredState?) -> String {
		guard let s = state else { return "" }
		return "AND answeredTerm = \(s.rawValue)"
	}
	
	private func answeredDefinitionString (state: AnsweredState?) -> String {
		guard let s = state else { return "" }
		return "AND answeredDefinition = \(s.rawValue)"
	}
	
	private func showOnlyFavoritesString (show: Bool?) -> String {
		guard let s = show else { return "" }
		return s ? "AND isFavorite = 1" : ""
	}
	
	private func learnedFlashcardString (learned: Bool?) -> String {
		guard let l = learned else {return ""}
		return l ? "AND learnedFlashcard = 1" : ""
	}
	
	private func nameContainsString (search: String? ) -> String {
		guard let s = search else {return ""}
		return "AND name LIKE '%\(s)%' "
	}
	
	private func nameStartsWithString (search: String? ) -> String {
		guard let s = search else {return ""}
		return "AND (name LIKE '\(s)%' OR name LIKE '-\(s)%')"
	}
	
	// this is ONLY added for getTermID as that is the only SELECT that will make this virtual column for ordering
	
	private func orderByNameString (toOrder: Bool?) -> String {
		guard let _ = toOrder else {return ""}
		return "ORDER BY noHyphenInName"
	}
		
	// End WHERE string components
	
}

