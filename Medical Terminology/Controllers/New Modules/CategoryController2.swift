//
//  CategoryController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/24/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class CategoryController2 {
	
	// to make the table name shorter and convenient
	let categories =  myConstants.dbTableCategories2
	let assignedCategories = myConstants.dbTableAssignedCategories
	let mainSectionCategories = myConstants.dbTableMainSectionCategories
	
	// controllers
	let tc = TermController()
		
	func getCategory (categoryID: Int) -> Category2 {
		
		let query = "SELECT * from \(categories) WHERE categoryID = \(categoryID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: [categoryID]) {
			if resultSet.next() {
				return fillCategory(resultSet: resultSet)
			} else {
				print("fatal error did not find category with id = \(categoryID) in getCategory. Returning empty category")
				return Category2()
			}
			
		} else {
			print("Fatal error getting the result set in getCategories function")
			return Category2()
		}
		
	}
	
	func getCountOfTerms (categoryID: Int) -> Int {
		
		let query = "SELECT COUNT (*) FROM \(assignedCategories) WHERE categoryID = \(categoryID)"
		
		
		
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return Int(resultSet.int(forColumnIndex: 0))
			
			
		} else {
			print ("fatal error making result set in getCountOfTerms, returning 0")
			return 0
		}
	}
	
	/*
	return all categories ordered by displayOrder
	*/
	func getCategories (categoryType: CategoryType) -> [Category2] {
		
		var query: String
		var cs = [Category2]()
		
		if categoryType == .custom {
			query = "SELECT * from \(categories) WHERE isStandard = \(categoryType.rawValue) ORDER BY displayOrder"
		} else {
			query = "SELECT * from \(categories) WHERE isStandard = \(categoryType.rawValue) ORDER BY displayOrder"
		}
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let c = fillCategory(resultSet: resultSet)
				cs.append(c)
			}
			return cs
		} else {
			print("fatal error making resultSet in getCategories")
			return cs
		}
		
	}
	
	func toggleAssignedCategory (termID: Int, categoryID: Int) {
		/*
		Will look at the term type (standard vs custom) and categoryID type (standard vs custom, All Terms, My Terms) and toggle the membership IF it is allowed
		
		RULE 1
		if the term is a standard term:
		may not assign or unassign from standard category
		
		RULE 2
		if this is a custom term:
		may not assign or unassign from category id 1 and 2

		otherwise :
		if the term is already assigned to the custom category, unassign it → notification :
			termRemovedFromCategory (termID, categoryID)

		if the term is not assigned to the category, then assign it → notification:
		termAssignedToCategory (termID, categoryIDdb
		*/
		
		let term = tc.getTerm(termID: termID)
		let category = getCategory(categoryID: categoryID)
		
		if term.isStandard && category.isStandard {
			// RULE 1
			// do nothing
			return
		}
		 
		if !term.isStandard && categoryID <= 2 {
			// RULE 2
			// do nothing
			return
		}
		
		// is this term already assigned to this category?
		let currentIDs = tc.getTermCategoryIDs(termID: termID)
		
		if currentIDs.contains(categoryID) {
			//this category is already assigned to this term, so need to remove it
			unassignCategory(termID: termID, categoryID: categoryID)
			
		} else {
			//this category is not assigned to this term, so need to add it
			assignCategory(termID: termID, categoryID: categoryID)
		}
		
	}
	
	func assignCategory (termID: Int, categoryID: Int) {
		let query = "INSERT INTO \(assignedCategories) ('termID', 'categoryID') VALUES (\(termID), \(categoryID))"
		myDB.executeStatements(query)
		
		// send out notification
		let data = ["termID" : termID, "categoryID" : categoryID]
		let name = Notification.Name(myKeys.termAssignedCategoryNotification)
		NotificationCenter.default.post(name: name, object: self, userInfo: data)
	}
	
	func unassignCategory (termID: Int, categoryID: Int) {
		let query = "DELETE FROM \(assignedCategories) WHERE termID = \(termID) AND categoryID = \(categoryID)"
		myDB.executeStatements(query)
		
		// send out notification
		// send out notification
		let data = ["termID" : termID, "categoryID" : categoryID]
		let name = Notification.Name(myKeys.termUnassignedCategoryNotification)
		NotificationCenter.default.post(name: name, object: self, userInfo: data)
	}
	
	private func fillCategory (resultSet: FMResultSet) -> Category2 {
		let categoryID = Int(resultSet.int(forColumn: "categoryID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let description = resultSet.string(forColumn: "description") ?? ""
		let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
		let isStandard = Int(resultSet.int(forColumn: "isStandard"))
		
		let c = Category2 (categoryID: categoryID,
						  name: name,
						  description: description,
						  displayOrder: displayOrder,
						  isStandard: isStandard == 1 ? true : false,
						  count: 0		// will need to update this when the program needs
		)
		
		return c
	}
	
	// MARK: -Add category functions
	func isCategoryNameDuplicate (name: String) -> Bool {
		
		let query = "SELECT COUNT(*) FROM \(myConstants.dbTableCategories2) WHERE name = '\(name)'"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let c = Int(resultSet.int(forColumnIndex: 0))
			
			return c > 0 ? true : false
		} else {
			print("fatal error did not get rs in isCategoryNameDuplicate. returning true")
			return true
		}
		
	}
	
	/*
	shoot off notification of category creation
	*/
	func addCustomCategory (categoryName: String) {
		// if duplicate name do not add it
		// always add with display order = 1
		// shift display order of other custom categories up by 1 to make room
		// return true on success
		// return false on not successful
		
		let moveQuery = "UPDATE \(myConstants.dbTableCategories2) SET displayOrder = displayOrder + 1 WHERE isStandard = 0"
		
		let _ = myDB.executeStatements(moveQuery)
		
		let addQuery = "INSERT INTO \(myConstants.dbTableCategories2) (name, description, isStandard, displayOrder) VALUES ('\(categoryName)', 'initial description', 0, 1)"
		
		let _ = myDB.executeStatements(addQuery)
		
		// need to shoot off categoryAddedNotification
		// the only item that will need to respond to it is the categoryListVCH so it can refresh the categoryListCV list
		
		let name = Notification.Name(myKeys.categoryAddedNotification)
		NotificationCenter.default.post(name: name, object: self, userInfo: nil)
	}
	
}

