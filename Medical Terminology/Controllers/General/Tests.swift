//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	
	let tc = TermController()
	init() {
		
		
			
		}
		
	func testStatements () -> [Int] {
		let ids = tc.getTermIDs(categoryID: 1, showFavoritesOnly: false, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none, nameContains: "ha", nameStartingWith: .none)
		return ids
	}

	
}
