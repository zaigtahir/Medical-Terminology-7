//
//  UserCategoryController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/16/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

let userTable = myConstants.dbTableUser

class UserCategoryController {
	//manage entries in the userCategory table the user uses to assign custom categories
	
	func addToCustomCategory (itemID: Int, categoryID: Int) {
		//if this is a duplicate then don't add it
		
		let query = "SELECT COUNT (*) FROM \(userTable) WHERE (itemID = \(itemID) AND categoryID = \(categoryID))"
		if let rs = myDB.executeQuery(query, withArgumentsIn: []) {
			rs.next()
			if Int(rs.int(forColumnIndex: 0)) == 0 {
				let query = "INSERT INTO \(userTable) (itemID, categoryID) VALUES(\(itemID), \(categoryID))"
				myDB.executeStatements(query)
			}
		}
	}
	
	func removeFromCutomCategoy (itemID: Int, categoryID: Int) {
		let query = "DELETE FROM \(userTable) WHERE (itemID = \(itemID) AND categoryID = \(categoryID))"
		myDB.executeStatements(query)
	}
}
