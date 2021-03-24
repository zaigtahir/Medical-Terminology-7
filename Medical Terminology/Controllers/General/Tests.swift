//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	
	func testFullQuery () {
		
		let tc = TermController()
		let query1 = tc.fullQuery(categoryID: 1, showOnlyFavorites: .none, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
		print (query1)
		
		
		let query2 = tc.fullQuery(categoryID: 2, showOnlyFavorites: true, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: false)
		print (query2)
		
		let query3 = tc.fullQuery(categoryID: 2, showOnlyFavorites: true, isFavorite: .none, answeredTerm: .incorrect, answeredDefinition: .correct, learned: true, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: true)
		
		print (query3)
	}
	
	
	
	
}
