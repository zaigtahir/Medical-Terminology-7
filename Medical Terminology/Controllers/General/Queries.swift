//
//  Queries.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/18/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Queries {

	// MARK: -WHERE string components
	
	func categoryString (categoryIDs: [Int]) -> String {
		// categoryID = 1
		// (categoryID = 2 OR categoryID = 3)
		
		if categoryIDs.count == 0 {
			return ""
		}
		
		var str = "("
		
		for i in 0...categoryIDs.count {
			if i == 0 {
				str.append("categoryID = \(categoryIDs[i])")
			}
			
			if i > 0 && i < categoryIDs.count {
				str.append(" OR categoryID = \(categoryIDs[i])")
			}
			
			
			if i == categoryIDs.count {
				str.append(")")
			}
		}
		return str
	}
	
	func favorteString (isFavorite: Bool?) -> String {
		
		// "" or "AND isFavorite = n"
		guard let f = isFavorite else { return "" }
		return f ? "AND isfavorite = 1" : "AND isfavorite = 0"
	}
	
	func showFavoritesOnly (show: Bool?) -> String {
		guard let s = show else { return "" }
		return s ? "AND isFavorite = 1" : ""
	}
	
	// if true order by noHyphenInName, if false, random order
	func orderByNameString (toOrder: Bool?) -> String {
		guard let _ = toOrder else {return ""}
		
		if toOrder! {
			return "ORDER BY LOWER (noHyphenInName)"
		} else {
			return "ORDER BY RANDOM ()"
		}
	}

	func learnedString (learned: Bool?) -> String {
		guard let l = learned else { return "" }
		return l ? "AND (learnedTerm = 1 AND learnedDefinition = 1)" : "AND (learnedTerm = 0 OR learnedDefinition = 0)"
	}
	
	func learnedTermString (learnedTerm: Bool?) -> String {
		guard let lt = learnedTerm else { return ""}
		return lt ? "AND learnedTerm = 1" : "AND learnedTerm = 0"
	}
	
	func learnedDefinitionString (learnedDefinition: Bool?) -> String {
		guard let ld = learnedDefinition else { return ""}
		return ld ? "AND learnedDefinition = 1" : "AND learnedDefinition = 0"
	}
	
	func answeredTermString (state: AnsweredState?) -> String {
		guard let s = state else { return "" }
		return "AND answeredTerm = \(s.rawValue)"
	}
	
	func answeredDefinitionString (state: AnsweredState?) -> String {
		guard let s = state else { return "" }
		return "AND answeredDefinition = \(s.rawValue)"
	}
	
	func learnedFlashcardString (learned: Bool?) -> String {
		guard let l = learned else {return ""}
		return l ? "AND learnedFlashcard = 1" : "AND learnedFlashcard  =  0"
	}
	
	func nameContainsString (search: String? ) -> String {
		guard let s = search else {return ""}
		return "AND name LIKE '%\(s)%' "
	}
	
	func containsTextString (search: String?) -> String {
		guard let s = search else {return ""}
		return "AND ((name LIKE '%\(s)%') OR (definition LIKE '%\(s)%')) "
	}
	
	func nameStartsWithString (search: String? ) -> String {
		guard let s = search else {return ""}
		return "AND (name LIKE '\(s)%' OR name LIKE '-\(s)%')"
	}

	
	func limitToString (limit: Int?) -> String {
		guard let _ = limit else {return ""}
		return "LIMIT \(limit!)"
	}
	
}
