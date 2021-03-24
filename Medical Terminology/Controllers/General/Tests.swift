//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	
	func testQueries () {
		
	let tc = TermController()
		tc.getCount(categoryID: 2, isFavorite: true, answeredTerm: .correct, answeredDefinition: .correct, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
		
	}
	
	
	
	
}
