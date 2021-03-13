//
//  Tests.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Tests {
	func makeWhereString () {
		let itemCounts = DItemCounts()
		
		print ("all values entered")
		let a = itemCounts.whereString(categoryID: 8, isFavorite: true, answeredTerm: .correct, answeredDefinition: .incorrect, learnedState: true)
		print (a)
		
		print ("only favorites entered")
		let b = itemCounts.whereString(categoryID: .none, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learnedState: .none)
		print (b)
	}
}
