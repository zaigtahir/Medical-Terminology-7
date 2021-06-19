//
//  AssignedCategoryController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/14/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class AssignedCategoryController {
	
	let sc = SettingsController()
	
	// to make the table name shorter and convenient
	let categories =  myConstants.dbTableCategories
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	func saveAssignedCategoryForMigration (assignedCategory ac: AssignedCategory) {
				
		let query = """
					INSERT INTO \(assignedCategories)
					(termID, categoryID)
					VALUES (\(ac.termID), \(ac.categoryID))
					"""
		
		myDB.executeStatements(query)
		
		
	}
	
	// MARK: OMG there i no learnedAnswer
	func getAssignedCategoryFromResultSet (resultSet rs: FMResultSet) -> AssignedCategory {
		
		let ac = AssignedCategory()
		
		ac.termID = 		Int(rs.int(forColumn: "termID"))
		ac.categoryID =		Int(rs.int(forColumn: "categoryID"))
		
		return ac
		
	}
	
	
	
	
	
}
