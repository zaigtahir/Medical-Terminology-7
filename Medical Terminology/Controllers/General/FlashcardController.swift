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
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	let categories = myConstants.dbTableCategories2
	
	func getFlashcardTermIDs (categoryID: Int, favoritesOnly: Bool, learnedStatus: Bool) -> [Int] {
		
		var favoriteString = ""
		
		if favoritesOnly {
			favoriteString = " AND isFavorite = 1 "
		}
		
		var learnedString = " AND learnedFlashcard = 0 "
		
		if learnedStatus {
			learnedString = " AND learnedFlashcard = 1 "
		}
		
		let query =  """
		SELECT termID FROM \(assignedCategories)
		WHERE categoryID = \(categoryID)
		\(learnedString)
		\(favoriteString)
		"""
		
		print("flashcardController getFlashcardTermIDs query: \(query)")
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		print("result count =  : \(ids.count)")
		
		return ids

	}
	
	func getFlashcardCount (categoryID: Int, favoritesOnly: Bool, learnedStatus: Bool) -> Int {
	
		var favoriteString = ""
		
		if favoritesOnly {
			favoriteString = " AND isFavorite = 1 "
		}
		
		var learnedString = " AND learnedFlashcard = 0 "
		
		if learnedStatus {
			learnedString = " AND learnedFlashcard = 1 "
		}
		
		let query = """
		SELECT COUNT (*) FROM \(assignedCategories)
		WHERE categoryID = \(categoryID)
		\(learnedString)
		\(favoriteString)
		"""
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		}
		
		return count
		
	}
	
	func flashcardIsLearned (categoryID: Int, termID: Int) -> Bool {
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
	
	/// Will reset all learnedFlashcard status to 0 (false)
	func resetLearnedFlashcards (categoryID: Int) {
		
		let query = "UPDATE \(assignedCategories) SET learnedFlashcard = 0 WHERE categoryID = \(categoryID)"
		myDB.executeStatements(query)
	}

}

