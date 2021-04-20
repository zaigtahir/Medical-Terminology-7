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
	let categories = myConstants.dbTableCategories2
	
	let cc = CategoryController2()
	
	func getTerm (termID: Int) -> Term {
		
		let query = "SELECT * FROM \(terms) WHERE termID = \(termID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			
			let termID = Int(resultSet.int(forColumn: "termID"))
			let name = resultSet.string(forColumn: "name") ?? ""
			let definition = resultSet.string(forColumn: "definition")  ?? ""
			let example = resultSet.string(forColumn: "example")  ?? ""
			let myNotes = resultSet.string(forColumn: "myNotes") ?? ""
			let secondCategoryID = Int(resultSet.int(forColumn: "secondCategoryID"))
			let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
			let s = Int(resultSet.int(forColumn: "isStandard"))
			
			let term = Term(termID: termID, name: name, definition: definition, example: example, myNotes: myNotes, secondCategoryID: secondCategoryID, audioFile: audioFile, isStandard: s == 1)
			
			return term
			
		} else {
			print("fatal error could not make result set or get term in getTerm")
			return Term()
		}
	}
	
	func setFavoriteStatusPN (categoryID: Int, termID: Int, isFavorite: Bool) {
		
		let query = "UPDATE \(assignedCategories) SET isFavorite = \( isFavorite ? 1 : 0 ) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		_ = myDB.executeStatements(query)
		
		// fire off notification that a terms information changed
		
		let data = ["categoryID" : categoryID, "termID" : termID]
		
		print ("In TermController: setFavoriteStatusPostNotification, posting this notification")
		
		let name = Notification.Name(myKeys.setFavoriteStatusKey)
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
		
		/*
		SELECT assignedCategories.categoryID, categories2.name
		FROM assignedCategories
		JOIN categories2 ON assignedCategories.categoryID = categories2.categoryID
		WHERE assignedCategories.termID = 1
		AND categories2.isStandard = 1
		*/
		
		// using a local function :)
		func getQuery (termID: Int, isStandard: Int) -> String {
			let query = """
				SELECT \(assignedCategories).categoryID, \(categories).categoryID
				FROM \(assignedCategories)
				JOIN \(categories) ON \(assignedCategories).categoryID = \(categories).categoryID
				WHERE \(assignedCategories).termID = \(termID)
				AND \(categories).isStandard = \(isStandard)
				"""
			return query
		}
		
		
		// first add the custom categories
		
		if let resultSet = myDB.executeQuery(getQuery(termID: termID, isStandard: 0), withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		} else {
			print ("fatal error getting result set in getTermCategoryIDs")
		}
		
		// then add standard categories so they are on the bottom when displaying them
		
		if let resultSet = myDB.executeQuery(getQuery(termID: termID, isStandard: 1), withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		} else {
			print ("fatal error getting result set in getTermCategoryIDs")
		}
		
		
		return ids
		
	}
	
	func getLearnedFlashcard (categoryID: Int, termID: Int) -> Bool {
		let query = "SELECT learnedFlashcard FROM \(assignedCategories) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let status = Int(resultSet.int(forColumnIndex: 0))
			return status == 1 ?  true : false
		} else {
			print ("fatal error getting resultSet in getLearnedFlashcardStatus, returning false")
			return false
		}
	}
	
	func setLearnedFlashcard (categoryID: Int, termID: Int, learnedStatus: Bool) {
		
		var ls = 0
		if learnedStatus {
			ls = 1
		}
		
		
		let query = "UPDATE \(assignedCategories) SET learnedFlashcard = \(ls) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		
		myDB.executeStatements(query)
		
	}

	/**
	Not including TermID is used to filter out the current term name. The user just might want to change the letter CaSE. In that case, i still want to save that change. So This query will look for duplicates of any other row.
	*/
	func termNameIsUnique (name: String, notIncludingTermID: Int) -> Bool {
		let query = "SELECT COUNT (*) FROM \(terms) WHERE name LIKE '\(name)' AND termID != \(notIncludingTermID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let count = Int (resultSet.int(forColumnIndex: 0))
			
			if count > 0 {
				return false
			} else {
				return true
			}
			
		} else {
			print("fatal error making RS in termNameisDuplicate. returning false as safety default")
			return false
		}
	}
	
	/**
	will save the term to the database creating a new row in the terms table
	will assign catetory All Terms, My Terms and any other that are in term.assignedTerms
	Wil return the termID of the added term
	*/
	func saveTerm (term: Term) -> Int {
		
		// saving a custom term with secondCategory = 2 and isStandard value is redundant, but makes for smoother programming
		
		let query  = "INSERT INTO \(terms) (name, definition, example, myNotes, isStandard, secondCategoryID) VALUES ('\(term.name)', '\(term.definition)', '\(term.example)', '\(term.myNotes)', 0, 2)"
				
		myDB.executeStatements(query)
	
		let addedTermID = Int(myDB.lastInsertRowId)
			
		for c in term.assignedCategories {
			cc.assignCategoryPN(termID: addedTermID, categoryID: c)
		}
		
		return addedTermID
		
	}
	
	// MARK: - term update functions
	
	func updateTermNamePN (termID: Int, name: String) {
		let query = "UPDATE \(terms) SET name = '\(name)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.changeTermInfoKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
	}
	
	func updateTermExamplePN (termID: Int, example: String) {
		let query = "UPDATE \(terms) SET example = '\(example)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.changeTermInfoKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
	}
	
	func updateTermDefinitionPN (termID: Int, definition: String) {
		
		let query = "UPDATE \(terms) SET definition = '\(definition)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.changeTermInfoKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
	}
	
	func updateTermMyNotesPN (termID: Int, myNotes: String) {
		
		let query = "UPDATE \(terms) SET myNotes = '\(myNotes)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.changeTermInfoKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
		
	}
	
	func deleteTermPN (termID: Int) {
		// delete from the term table. The term deletion does not need to PN
		let query1 = "DELETE FROM \(terms) WHERE termID = \(termID)"
		let _ = myDB.executeStatements(query1)
		
		// unassign from assignedCategories and PN
		
		let ids = self.getTermCategoryIDs(termID: termID)
		for id in ids {
			cc.unassignCategoryPN(termID: termID, categoryID: id)
		}
	}
	
	// MARK: - Non search text queries
	
	func getTermIDs (categoryID: Int, showFavoritesOnly: Bool?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?, orderByName: Bool?) -> [Int]{
		
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
												  orderByName: orderByName)
		
		let query = ("\(selectStatement) \(whereStatement)")
		
		print("getTermIDs query: \(query)")
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		return ids
	}
	
	func getCount (categoryID: Int, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?) -> Int {
		
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
												 orderByName: .none)
		
		let query = ("\(selectStatement) \(whereStatement)")
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		}
		
		return count
		
	}
	
	private func whereStatement (categoryID: Int, showOnlyFavorites: Bool?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?, orderByName: Bool?) -> String {
		
		let showOnlyFavoritesString = self.showOnlyFavoritesString(show: showOnlyFavorites)
		let favoriteString = self.favorteString(isFavorite: isFavorite)
		let learnedString = self.learnedString(learned: learned)
		let learnedTermString = self.learnedTermString(learnedTerm: learnedTerm)
		let learnedDefinitionString = self.learnedDefinitionString(learnedDefinition: learnedDefinition)
		let answeredTermString = self.answeredTermString(state: answeredTerm)
		let answeredDefinitionString = self.answeredDefinitionString(state: answeredDefinition)
		let learnedFlashcardString = self.learnedFlashcardString(learned: learnedFlashcard)
		let orderByNameString = self.orderByNameString(toOrder: orderByName)
		
		// need to add ORDER BY
		
		let whereStatement = "WHERE \(assignedCategories).categoryID = \(categoryID) \(favoriteString) \(showOnlyFavoritesString) \(learnedString) \(learnedTermString) \(learnedDefinitionString) \(answeredTermString) \(answeredDefinitionString) \(learnedFlashcardString ) \(orderByNameString)"
		
		return whereStatement
	}
	
	
	// MARK: - Search text queries
	
	/**
	Return list of termIDs.
	use nameStartsWith with nameContains OR containsText and loop through the alphabet to make an alphabetic list
	containsText searches terms and definitions
	*/
	func searchTermIDs (categoryID: Int, isFavorite: Bool?, nameStartsWith: String, nameContains: String?, containsText: String?) -> [Int] {
		var definitionString = ""
		if containsText != nil {
			definitionString = ", definition"
		}
		
		let selectStatement = "SELECT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName \(definitionString) FROM \(terms) JOIN \(assignedCategories) ON \(terms).termID = \(assignedCategories).termID "
		
		let whereStatement = "WHERE categoryID = \(categoryID) \(favorteString(isFavorite: isFavorite)) \(nameStartsWithString(search: nameStartsWith)) \(nameContainsString(search: nameContains)) \(containsTextString(search: containsText)) \(orderByNameString(toOrder: true))"
		
		let query = ("\(selectStatement) \(whereStatement)" )
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		return ids
	}
	
	
	// MARK: -WHERE string components
	
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
		return l ? "AND learnedFlashcard = 1" : "AND learnedFlashcard  =  0"
	}
	
	private func nameContainsString (search: String? ) -> String {
		guard let s = search else {return ""}
		return "AND name LIKE '%\(s)%' "
	}
	
	private func containsTextString (search: String?) -> String {
		guard let s = search else {return ""}
		return "AND ((name LIKE '%\(s)%') OR (definition LIKE '%\(s)%')) "
	}
	
	private func nameStartsWithString (search: String? ) -> String {
		guard let s = search else {return ""}
		return "AND (name LIKE '\(s)%' OR name LIKE '-\(s)%')"
	}
	
	// this is ONLY added for getTermID as that is the only SELECT that will make this virtual column for ordering
	
	private func orderByNameString (toOrder: Bool?) -> String {
		guard let _ = toOrder else {return ""}
		return "ORDER BY LOWER (noHyphenInName)"
	}
	
}

