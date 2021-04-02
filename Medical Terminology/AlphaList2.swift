//
//  AlphaList2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/1/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

// a class to hold an list of termIDs in sections a-z

class AlphaList2 {
	
	private let tc = TermController()
	
	private var sectionNames = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	
	private var termIDsList = [[Int]] ()
	
	func makeList (categoryID: Int, showFavoritesOnly: Bool?, nameContains: String?) {
		
		for s in sectionNames {
			
			let termIDs = tc.getTermIDs(categoryID: categoryID, showFavoritesOnly: showFavoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none, nameContains: nameContains, nameStartsWith: .none, orderByName: true)
			
			termIDsList.append(termIDs)
		}
	}
	
	func getSectionName (section: Int) -> String {
		return sectionNames[section]
	}
	
	func getTermIDs (section: Int) -> [Int] {
		return termIDsList[section]
	}
	
}
