//
//  TermController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/23/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

class TermController {
	
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
	
	private func makeTerm (resultSet: FMResultSet) -> Term {
		
		let termID = Int(resultSet.int(forColumn: "termID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let definition = resultSet.string(forColumn: "definition")  ?? ""
		let example = resultSet.string(forColumn: "example")  ?? ""
		let secondCategoryID = Int(resultSet.int(forColumn: "secondCategoryID"))
		let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
		let f = Int(resultSet.int(forColumn: "isFavorite"))
		let m = Int(resultSet.int(forColumn: "isMyTerm"))
		
		let term = Term(termID: termID, name: name, definition: definition, example: example, secondCategoryID: secondCategoryID, audioFile: audioFile, isFavorite: f == 1, isMyTerm: m == 1)
		
		return term
	}
	
	// MARK: Private functions
	
	func fullQuery (categoryID: Int, showOnlyFavorites: Bool?, isFavorite: Bool?, answeredTerm: AnsweredState?, answeredDefinition: AnsweredState?, learned: Bool?, learnedTerm: Bool?, learnedDefinition: Bool?, learnedFlashcard: Bool?) -> String {
		
		/*
		SELECT terms.termID, terms.isFavorite, assignCategories2.categoryID
		FROM terms
		JOIN  assignCategories2 ON terms.termID = assignCategories2.termID
		WHERE assignCategories2.categoryID = 3
		*/
		
		let terms = myConstants.dbTableTerms
		let assignedCategories = myConstants.dbTableAssignedCategories
		
		let showOnlyFavoritesString = self.showOnlyFavoritesString(show: showOnlyFavorites)
		
		let favoriteString = self.favorteString(isFavorite: isFavorite)
		
		let learnedString = self.learnedString(learned: learned)
		let learnedTermString = self.learnedTermString(learnedTerm: learnedTerm)
		let learnedDefinitionString = self.learnedDefinitionString(learnedDefinition: learnedDefinition)
		
		let answeredTermString = self.answeredTermString(state: answeredTerm)
		let answeredDefinitionString = self.answeredDefinitionString(state: answeredDefinition)
		
		let learnedFlashcardString = self.learnedFlashcardString(learned: learnedFlashcard)
		
		let selectStatement = "SELECT \(terms).termID FROM \(terms) JOIN \(assignedCategories) ON \(terms).termID = \(assignedCategories).termID "
		
		let whereStatement = "WHERE \(assignedCategories).categoryID = \(categoryID) \(favoriteString) \(showOnlyFavoritesString) \(learnedString) \(learnedTermString) \(learnedDefinitionString) \(answeredTermString) \(answeredDefinitionString) \(learnedFlashcardString )"
		
		return ("\(selectStatement) \(whereStatement)")
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
	
	// End WHERE string components
	
	
	
}

