//
//  AssignedCategoryController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/14/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class AssignedCategoryController {
	
	// to make the table name shorter and convenient
	let categories =  myConstants.dbTableCategories
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	func saveAssignedCategoryForMigration (assignedCategory ac: AssignedCategory) {
				
		let query = """
					INSERT INTO \(assignedCategories)
					(termID, categoryID, isFavorite, learnedTerm, learnedDefinition,
					answeredTerm, answeredDefinition, learnedFlashcard)

					VALUES (\(ac.termID), \(ac.categoryID), \(ac.isFavorite),
					\(ac.learnedTerm), \(ac.learnedDefinition),
					\(ac.answeredTerm), \(ac.answeredDefinition), \(ac.learnedFlashcard)
					"""
		
		myDB.executeStatements(query)
		
	}
	
	func getAssignedCategoryFromResultSet (resultSet rs: FMResultSet) -> AssignedCategory {
		
		let ac = AssignedCategory()
		
		ac.termID = 		Int(rs.int(forColumn: "termID"))
		ac.categoryID =		Int(rs.int(forColumn: "categoryID"))
		ac.isFavorite = 	Int(rs.int(forColumn: "isFavorite"))
		ac.learnedTerm = 	Int(rs.int(forColumn: "learnedTerm"))
		ac.learnedDefinition = Int(rs.int(forColumn: "learnedDefinition"))
		ac.learnedFlashcard = Int(rs.int(forColumn: "learnedFlashcard"))
		
		return ac
		
	}
	
	
	
	
	
}
