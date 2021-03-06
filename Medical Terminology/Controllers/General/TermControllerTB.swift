//
//  TermControllerTB.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/18/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

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


// This will be used for the term based flow
// will use the expanded term colums data


// MARK: -TODO - have to modify query to get DISTINCT

class TermControllerTB {
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories

	let categories = myConstants.dbTableCategories
	
	let cc = CategoryController()
	let sc = SettingsController()
	let queries = Queries()
	
	func termExists (termID: Int) -> Bool {
		let query = "SELECT COUNT (*) FROM \(terms) WHERE termID = \(termID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			
			let count = Int (resultSet.int(forColumnIndex: 0))
			if count > 0 {
				return true
			} else {
				return false
			}
			
		} else {
			print("termExists: fatal error could not make result set, return false")
			return false
		}
		
	}
	
	func getTerm (termID: Int) -> Term2 {
		
		let query = "SELECT * FROM \(terms) WHERE termID = \(termID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			
			return getTermFromResultSet(resultSet: resultSet)
			
		} else {
			print("fatal error could not make result set or get term in getTerm")
			return Term2()
		}
	}
	
	func getTermFromResultSet(resultSet: FMResultSet) -> Term2 {
		
		let term = Term2()
		
		
		term.termID = Int(resultSet.int(forColumn: "termID"))
		term.name = resultSet.string(forColumn: "name") ?? ""
		term.definition = resultSet.string(forColumn: "definition")  ?? ""
		term.example = resultSet.string(forColumn: "example")  ?? ""
		term.myNotes = resultSet.string(forColumn: "myNotes") ?? ""
		term.secondCategoryID = Int(resultSet.int(forColumn: "secondCategoryID"))
		term.thirdCategoryID = Int(resultSet.int(forColumn: "thirdCategoryID"))
		term.audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
		
		let isStandard = Int(resultSet.int(forColumn: "isStandard"))
		let isFavorite = 	Int(resultSet.int(forColumn: "isFavorite"))
		let learnedTerm = 	Int(resultSet.int(forColumn: "learnedTerm"))
		let learnedDefinition = Int(resultSet.int(forColumn: "learnedDefinition"))
		let learnedFlashcard = Int(resultSet.int(forColumn: "learnedFlashcard"))
		
		term.isStandard = isStandard == 1
		term.isFavorite = isFavorite == 1
		term.learnedTerm = learnedTerm == 1
		term.learnedDefinition = learnedDefinition == 1
		term.answeredTerm = Int(resultSet.int(forColumn: "answeredTerm"))
		term.answeredDefinition = Int(resultSet.int(forColumn: "answeredDefinition"))
		
		term.learnedFlashcard = learnedFlashcard == 1
		
		return term
	}
	
	func setFavoriteStatusPN (termID: Int, isFavorite: Bool) {
		
		let query = "UPDATE \(terms) SET isFavorite = \( isFavorite ? 1 : 0 ) WHERE (termID = \(termID))"
		_ = myDB.executeStatements(query)
		
		// fire off notification that a term favorite status changed
		
		let data = ["termID" : termID]
				
		let name = Notification.Name(myKeys.setFavoriteStatusKey)
		NotificationCenter.default.post(name: name, object: self, userInfo: data)
	}
	
	func getFavoriteStatus (termID: Int ) -> Bool {
		let query = "SELECT isFavorite FROM \(terms) WHERE (termID = \(termID))"
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let status = Int(resultSet.int(forColumnIndex: 0))
			return status == 1 ?  true : false
		} else {
			print ("fatal error getting resultSet in getFavoriteStatus, returning false")
			return false
		}
	}
	
	func toggleFavoriteStatusPN (termID: Int) -> Bool {
		let favStatus = getFavoriteStatus(termID: termID)
		setFavoriteStatusPN(termID: termID, isFavorite: !favStatus)
		return !favStatus
	}
	
	func getTermCategoryIDs ( termID: Int) -> [Int] {
		
		var ids = [Int]()
		
		/*
		SELECT assignedCategories.categoryID, categories.name
		FROM assignedCategories
		JOIN categories ON assignedCategories.categoryID = categories2.categoryID
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
	
	/**
	Not including TermID is used to filter out the current term name. The user just might want to change the letter CaSE
	In that case, i still want to save that change. So This query will look for duplicates of any other row.
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
	will assign category All Terms, My Terms and any other that are in term.assignedCategories
	will save the favorite status of the term, as all other status will be false/unanswered
	If this is the first new term, it will create it at termID = dbCustomTermStartingID
	Will return the termID of the added term
	*/
	func saveNewTerm (term: Term2) -> Int {
		
		var query: String
		
		if termExists(termID: myConstants.dbCustomTermStartingID) {
			
			query = """
					INSERT INTO \(terms)
						(name,
						definition,
						example,
						myNotes,
						secondCategoryID,
						thirdCategoryID),
						audioFile,
						isStandard,
						isFavorite

					VALUES	("\(term.name)",
							"\(term.definition)",
							"\(term.example)",
							"\(term.myNotes)",
							2,
							\(term.thirdCategoryID))
							"\(term.audioFile)",
							0,
							\(term.isFavorite ? 1: 0)
					"""
		} else {
			
			query = """
					INSERT INTO \(terms)
						(termID,
						name,
						definition,
						example,
						myNotes,
						secondCategoryID,
						thirdCategoryID),
						audioFile,
						isStandard,
						isFavorite

					VALUES	(\(myConstants.dbCustomTermStartingID),
							"\(term.name)",
							"\(term.definition)",
							"\(term.example)",
							"\(term.myNotes)",
							2,
							\(term.thirdCategoryID))
							"\(term.audioFile)",
							0,
							\(term.isFavorite ? 1: 0)
					"""

		}
		
		myDB.executeStatements(query)
		
		let addedTermID = Int(myDB.lastInsertRowId)
		
		for c in term.assignedCategories {
			cc.assignCategoryPN(termID: addedTermID, categoryID: c)
		}
		
		if sc.isDevelopmentMode() {
			print ("termController saveNewTerm, created new term with ID: \(addedTermID)")
		}
		
		return addedTermID
		
	}
	
	/**
	Save a term to the db, use when migrating custom terms
	Copies everything including the termID
	*/
	func saveTermForMigration (term: Term2) {
		let query = """
				INSERT INTO \(terms)
					(termID,
					name,
					definition,
					example,
					myNotes,
					secondCategoryID,
					thirdCategoryID),
					audioFile,
					isStandard,
					isFavorite,
					learnedTerm,
					learnedDefinition,
					answeredTerm,
					answeredDefinition,
					learnedFlashcard

				VALUES	("\(term.termID)",
						"\(term.name)",
						"\(term.definition)",
						"\(term.example)",
						"\(term.myNotes)",
						"\(term.myNotes)",
						\(term.secondCategoryID),
						\(term.thirdCategoryID))
						"\(term.audioFile)",
						\(term.isStandard ? 1: 0),
						\(term.isFavorite ? 1: 0),
						\(term.learnedTerm ? 1: 0),
						\(term.learnedDefinition ? 1: 0),
						\(term.answeredTerm),
						\(term.answeredDefinition),
						\(term.learnedFlashcard),
				"""
		myDB.executeStatements(query)
		
		let addedTermID = Int(myDB.lastInsertRowId)
		
		if sc.isDevelopmentMode() {
			print ("termController saveNewTermForMigration, saved term with ID: \(addedTermID)")
		}
	}
	
	
	// MARK: - term update functions
	
	func updateTermNamePN (termID: Int, name: String) {
		let query = "UPDATE \(terms) SET name = '\(name)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.termInformationChangedKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
	}
	
	func updateTermExamplePN (termID: Int, example: String) {
		let query = "UPDATE \(terms) SET example = '\(example)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.termInformationChangedKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
	}
	
	func updateTermDefinitionPN (termID: Int, definition: String) {
		
		let query = "UPDATE \(terms) SET definition = '\(definition)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.termInformationChangedKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
	}
	
	func updateTermMyNotesPN (termID: Int, myNotes: String) {
		
		let query = "UPDATE \(terms) SET myNotes = '\(myNotes)' WHERE termID = \(termID)"
		myDB.executeStatements(query)
		
		// post notification
		let nName = Notification.Name(myKeys.termInformationChangedKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : termID])
		
	}
	
	func deleteTermPN (termID: Int) {
		// unassign from assignedCategories and PN
		
		let ids = self.getTermCategoryIDs(termID: termID)
		for id in ids {
			cc.unassignCategoryPN(termID: termID, categoryID: id)
		}
		
		
		// delete from the term table. The term deletion does not need to PN
		let query1 = "DELETE FROM \(terms) WHERE termID = \(termID)"
		let _ = myDB.executeStatements(query1)
		
	}
	
	
	// MARK: - search functions, need to use an array of categoryIDs
	
	func getTermIDs (categoryIDs: [Int], favoritesOnly: Bool?, orderByName: Bool?, limitTo: Int?) -> [Int] {
		
		let selectStatement = """
			SELECT DISTINCT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
		"""
		
		let whereStatement = """
			WHERE \(queries.categoryString(categoryIDs: categoryIDs))
			\(queries.showFavoritesOnly(show: favoritesOnly))
			\(queries.orderByNameString(toOrder: orderByName))
			\(queries.limitToString(limit: limitTo))
		"""
		
		let query = selectStatement.appending(whereStatement)
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		if sc.isDevelopmentMode() {
			print("getTermIDs2 query: \(query)")
			print("result count =  : \(ids.count)")
		}
		
		return ids
		
	}
	
	/**
	Return list of termIDs.
	use nameStartsWith with nameContains OR containsText and loop through the alphabet to make an alphabetic list
	containsText searches terms and definitions
	*/
	func getTermIDs (categoryIDs: [Int], isFavorite: Bool?, nameStartsWith: String, nameContains: String?, containsText: String?) -> [Int] {
		
		var definitionString = ""
		
		if containsText != nil {
			definitionString = ", definition"
		}
		
		let selectStatement = """
			SELECT DISTINCT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName
			\(definitionString)
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			"""
		
		let whereStatement = """
			WHERE categoryID = \(queries.categoryString(categoryIDs: categoryIDs))
			\(queries.favorteString(isFavorite: isFavorite))
			\(queries.nameStartsWithString(search: nameStartsWith))
			\(queries.nameContainsString(search: nameContains))
			\(queries.containsTextString(search: containsText))
			\(queries.orderByNameString(toOrder: true))
			"""
		
		let query = selectStatement.appending(whereStatement)
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		return ids
	}
	
	func getTermCount (categoryIDs: [Int], favoritesOnly: Bool) -> Int {
		
		
		//select COUNT(*) column_name FROM (SELECT DISTINCT column_name);
	
		var favoriteString = ""
		
		if favoritesOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		let query = """
			SELECT COUNT (*) FROM
			(SELECT DISTINCT \(assignedCategories).termID
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE \(queries.categoryString(categoryIDs: categoryIDs))
			\(favoriteString))
			"""
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		}
		
		return count
	}

}


