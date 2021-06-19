//
//  FlashcardController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/4/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class FlashcardController {
	
	// MARK: shorter table names to make things easier
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	let sc = SettingsController()
	
	let terms = myConstants.dbTableTerms
	
	let queries = Queries()
	
	func getFlashcardTermIDs (categoryIDs: [Int], showFavoritesOnly: Bool, learnedStatus: Bool) -> [Int] {
		
		let query = """
					SELECT DISTINCT \(terms).termID,
					REPLACE (name, '-' , '') AS noHyphenInName
					FROM \(terms)
					JOIN \(assignedCategories) ON \(terms).termID = \(assignedCategories).termID
					WHERE
					\(queries.categoryString(categoryIDs: categoryIDs))
					\(queries.learnedFlashcardString(learned: learnedStatus))
					\(queries.showFavoritesOnly(show: showFavoritesOnly))
					\(queries.orderByNameString(toOrder: true))
					"""
		
		var ids = [Int]()
		
		if sc.isDevelopmentMode() {
			print("getFlashcardTermIDs: query = \(query)")
		}
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		return ids

	}
	
	func getFlashcardCount (categoryIDs: [Int], showFavoritesOnly: Bool, learnedStatus: Bool) -> Int {
	
		let query = """
		SELECT COUNT (*) FROM
		(SELECT DISTINCT \(assignedCategories).termID
		FROM \(assignedCategories)
		WHERE
		\(queries.categoryString(categoryIDs: categoryIDs))
		\(queries.learnedString(learned: learnedStatus))
		\(queries.showFavoritesOnly(show: showFavoritesOnly)))
		"""
		
		if sc.isDevelopmentMode() {
			print("getFlashcardCount query: \(query)")
		}
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		}
		
		return count
		
	}
	
	func flashcardIsLearned (termID: Int) -> Bool {
		let query = "SELECT learnedFlashcard FROM \(terms) WHERE (termID = \(termID))"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let status = Int(resultSet.int(forColumnIndex: 0))
			return status == 1 ?  true : false
		} else {
			print ("fatal error getting resultSet in getLearnedFlashcardStatus, returning false")
			return false
		}
	}
	
	func setLearnedFlashcard (termID: Int, learnedStatus: Bool) {
		
		var ls = 0
		if learnedStatus {
			ls = 1
		}
		
		let query = "UPDATE \(terms) SET learnedFlashcard = \(ls) WHERE (termID = \(termID))"
		
		myDB.executeStatements(query)

	}
	
	/*
	Resets all learned to learning for the categories
	*/
	func resetLearnedFlashcards (categoryIDs: [Int]) {
		
		let query = """
			UPDATE \(terms)
			SET learnedFlashcard = 0
			\(queries.categoryString(categoryIDs: categoryIDs))
		"""
		
		myDB.executeStatements(query)
	}
	
}

