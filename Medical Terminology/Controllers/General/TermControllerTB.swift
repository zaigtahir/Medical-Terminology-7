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
	let utilities = Utilities()
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
	
	/**
	Will not fill assignedCategories
	*/
	func getTerm (termID: Int) -> TermTB {
		
		let query = "SELECT * FROM \(terms) WHERE termID = \(termID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			
			let term = getTermFromResultSet(resultSet: resultSet)
			term.assignedCategories = getTermCategoryIDs(termID: term.termID)
			return term
			
		} else {
			print("fatal error could not make result set or get term in getTerm")
			return TermTB()
		}
	}
	
	func getTermFromResultSet(resultSet: FMResultSet) -> TermTB {
		
		let term = TermTB()
		
		
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
	will assign each category in  term.assignedCategories to the assignedCategories table
	will save the favorite status of the term, as all other status will be false/unanswered
	If this is the first new term, it will create it at termID = dbCustomTermStartingID
	Will return the termID of the added term
	*/
	func saveNewTermPN (term: TermTB) -> Int {
		
		if term.termID != -1 {
			print("TermController : saveNewTermPN not allowed to save a new term when termID != -1, returning 0")
			return 0
		}
		
		
		var query: String
		
		if termExists(termID: myConstants.dbCustomTermStartingID) {
			
			query = """
					INSERT INTO \(terms)
						(name,
						definition,
						example,
						myNotes,
						secondCategoryID,
						thirdCategoryID,
						audioFile,
						isStandard,
						isFavorite)

					VALUES	("\(term.name)",
							"\(term.definition)",
							"\(term.example)",
							"\(term.myNotes)",
							2,
							\(term.thirdCategoryID),
							"\(term.audioFile)",
							0,
							\(term.isFavorite ? 1: 0))
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
						thirdCategoryID,
						audioFile,
						isStandard,
						isFavorite)

					VALUES	(\(myConstants.dbCustomTermStartingID),
							"\(term.name)",
							"\(term.definition)",
							"\(term.example)",
							"\(term.myNotes)",
							2,
							\(term.thirdCategoryID),
							"\(term.audioFile)",
							0,
							\(term.isFavorite ? 1: 0))
					"""
			
		}
		
		myDB.executeStatements(query)
		
		let addedTermID = Int(myDB.lastInsertRowId)
		
		for c in term.assignedCategories {
			cc.assignCategory(termID: addedTermID, categoryID: c)
		}
		
		// post notification
		let nName = Notification.Name(myKeys.termAddedKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : addedTermID])
		
		return addedTermID
		
	}
	
	/**
	will save updates to the db for this term using it's given ID
	will send off notifications if the name is changed or assigned categories are changed
	
	must have the tnew erm's assignCategoreis in place
	*/
	func updateTermPN (term: TermTB) {
		
		// the starting state of of the term with this ID from the database
		let originalTerm = getTerm(termID: term.termID)
		
		let query = """
			UPDATE \(terms)
			SET
			name = "\(term.name)",
			definition = "\(term.definition)",
			example = "\(term.example)",
			myNotes = "\(term.myNotes)",
			audiofile = "\(term.audioFile)",
			isFavorite = "\(term.isFavorite ? 1 : 0)"
			WHERE
			termID = \(term.termID)
		"""
		
		myDB.executeStatements(query)
		
		// update the categories if they are different
		
		let categoryIDsChanged = !utilities.containSameElements(array1: originalTerm.assignedCategories, array2: term.assignedCategories)
		
		if categoryIDsChanged {
			
			for cID in originalTerm.assignedCategories {
				cc.unassignCategory(termID: term.termID, categoryID: cID)
			}
			
			for cID in term.assignedCategories {
				cc.assignCategory(termID: term.termID, categoryID: cID)
			}
		}
		
		//MARK: this should be in higher controller
		
		// send out notification if the term name or categories have changed
		// the other changes in values will not affect other parts of the program
		
		if (originalTerm.name != term.name) || !categoryIDsChanged {
			
			let nName = Notification.Name(myKeys.termChangedKey)
			NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID" : term.termID])
		}
		
	}
	/**
	Save a term to the db, use when migrating custom terms
	Copies everything including the termID
	*/
	func saveTermForMigration (term: TermTB) {
		let query = """
				INSERT INTO \(terms)
					(termID,
					name,
					definition,
					example,
					myNotes,
					secondCategoryID,
					thirdCategoryID,
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
	
	func deleteTermPN (termID: Int) {
		
		let assignedCategoryIDs = self.getTermCategoryIDs(termID: termID)
		
		// remove the assignments from the assignedCategories table
		for id in assignedCategoryIDs {
			cc.unassignCategory(termID: termID, categoryID: id)
		}
		
		// delete from the term table
		let query1 = "DELETE FROM \(terms) WHERE termID = \(termID)"
		let _ = myDB.executeStatements(query1)
		
		// post notification
		let nName = Notification.Name(myKeys.termDeletedKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["assignedCategoryIDs" : assignedCategoryIDs])
		
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
		
		return ids
		
	}
	
	/*
	Return list of termIDs.
	containsText searches terms and definitions
	*/
	func getTermIDs (categoryIDs: [Int], showFavoritesOnly: Bool, nameStartsWith: String, nameContains: String?, containsText: String?) -> [Int] {
		
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
		
		// some space before WHERE is critical
		let whereStatement = """
				WHERE  \(queries.categoryString(categoryIDs: categoryIDs))
			\(queries.showFavoritesOnly(show: showFavoritesOnly))
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
	
	func getTermIDs_AssignTerms_AllTerms (nameStartsWith: String, nameContains: String?) -> [Int] {
		
		let s = nameStartsWith
		
		let query = """
			SELECT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE name LIKE '\(s)%' OR name LIKE '-\(s)%'
			\(queries.nameContainsString(search: nameContains))
			\(queries.orderByNameString(toOrder: true))
			"""
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		return ids
	}
	
	func getTermIDs_AssignTerms_AssignedOnly (assignedCategoryID: Int, nameStartsWith: String, nameContains: String?) -> [Int] {
		
		let s = nameStartsWith
		
		let query = """
			SELECT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE
			\(queries.categoryString(categoryIDs: [assignedCategoryID]))
			AND name LIKE '\(s)%' OR name LIKE '-\(s)%'
			\(queries.nameContainsString(search: nameContains))
			\(queries.orderByNameString(toOrder: true))
			"""
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		return ids
		
	}
	
	func getTermIDs_AssignTerms_UnassignedOnly (notAssignedCategoryID: Int, nameStartsWith: String, nameContains: String?) -> [Int] {
		
		let s = nameStartsWith
		
		let query = """
			SELECT \(terms).termID, REPLACE (name, '-' , '') AS noHyphenInName
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE
			CategoryID != \(notAssignedCategoryID)
			AND name LIKE '\(s)%' OR name LIKE '-\(s)%'
			\(queries.nameContainsString(search: nameContains))
			\(queries.orderByNameString(toOrder: true))
			"""
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		return ids
		
		
	}
	
	func getTermCount (categoryIDs: [Int], showFavoritesOnly: Bool) -> Int {
		
		let query = """
			SELECT COUNT (*) FROM
			(SELECT DISTINCT \(assignedCategories).termID
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE \(queries.categoryString(categoryIDs: categoryIDs))
			\(queries.showFavoritesOnly(show: showFavoritesOnly)))
			"""
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		}
		
		return count
	}
	
	
	
}


