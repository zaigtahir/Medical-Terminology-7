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
	
	func toggleAssignedCategoryBK (termID: Int, categoryID: Int) {
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
			unassignCategoryPN(termID: termID, categoryID: categoryID)
			
		} else {
			//this category is not assigned to this term, so need to add it
			assignCategoryPN(termID: termID, categoryID: categoryID)
		}
		
	}
	
	// MARK: - toggle category functions
	/**
	If the category is not already assigned, assign it (and vice versa), update the DB and reload the assigned categories in the term
	
	Note, this function is NOT updating the local term assignedCategories property. You will need to update that list when needed
	
	*/
	func toggleCategories (term: Term, categoryID: Int) {
		
		if term.assignedCategories.contains(categoryID) {
			//this category is already assigned to this term, so need to remove it
			unassignCategoryPN(termID: term.termID, categoryID: categoryID)
			
		} else {
			//this category is not assigned to this term, so need to add it
			assignCategoryPN(termID: term.termID, categoryID: categoryID)
		}
		
	}
	
	/**
	Update the categories just locally in the term, and nothing is saved to the DB
	Ideally want the sequence of the categories to be as if they were pulled from the db in the display order and custom on top
	*/
	func toggleCategoriesNewTermPN (term: Term, categoryID: Int) {
		
		if term.assignedCategories.contains(categoryID) {
			
			// need to remove it
			if term.assignedCategories.last == categoryID {
				term.assignedCategories.removeLast()
			} else {
				
				if let indexToRemove = term.assignedCategories.firstIndex(of: categoryID) {
					
					term.assignedCategories.remove(at: indexToRemove)
				}
				
			}
			
			// send out notification
			let data = ["termID" : term.termID, "categoryID" : categoryID]
			let name = Notification.Name(myKeys.unassignCategoryKey)
			NotificationCenter.default.post(name: name, object: self, userInfo: data)
			
			
		} else {
			
			// categoryID is not part of assignedCategories, so add to it
			term.assignedCategories.append(categoryID)
			
			// send out a term assigned notification so that the termVC can update itself
			
			// send out notification
			let data = ["termID" : term.termID, "categoryID" : categoryID]
			let name = Notification.Name(myKeys.assignCategoryKey)
			NotificationCenter.default.post(name: name, object: self, userInfo: data)
			
		}
		
		
	}
	
	private func sortAssignedCategories (term: Term) {
		// will take a array of [categoryID] and sort them. the custom categores will be first based on their display order, then the standard categories after based on their display order
		
		
		/*
		select categoryID, displayOrder from categories2 where categoryID = 1 OR categoryID = 3 OR categoryID = 6
		ORDER BY isStandard, displayOrder
		*/
		
		
		if term.assignedCategories.count == 0 {
			return
		}
		
		var query = "SELECT categoryID, isStandard, displayOrder FROM \(categories) WHERE categoryID = \(term.assignedCategories[0]) "
		
		for id in term.assignedCategories {
			
			if id != term.assignedCategories[0] { // skip the first one as I added that already
				query.append(" OR categoryID = \(id)")
			}
		}
		
		query.append("  ORDER BY isStandard, displayOrder")
		
		var orderedArray = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			
			while resultSet.next() {
				orderedArray.append(Int(resultSet.int(forColumnIndex: 0)))
			}
			
		} else {
			print ("fatal error not able to get result set in CategoryController sortAssignedCategoreis")
		}
		
		// reversing it so that it shows in the correct order
		orderedArray.reverse()
		
		// attaching the ordered list to the array
		term.assignedCategories = orderedArray
		
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
	
	// MARK: - Functions that send off program wide notifications
	
	func addCategoryPN (categoryName: String) {
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
		
		let name = Notification.Name(myKeys.addCategoryKey)
		NotificationCenter.default.post(name: name, object: self, userInfo: nil)
	}
	
	func deleteCategoryPN (categoryID: Int) {
		// will delete this category from the category table, and also remove all assignments from the assigned category
		
		let query1 = "DELETE FROM \(categories) WHERE categoryID = \(categoryID)"
		let _ = myDB.executeStatements(query1)
		
		let query2 = "DELETE FROM \(assignedCategories) WHERE categoryID = \(categoryID)"
		let _ = myDB.executeStatements(query2)
		
		let name = Notification.Name(myKeys.deleteCategoryKey)
		NotificationCenter.default.post(name: name, object: self, userInfo: ["categoryID": categoryID])
	}
	
	func changeCategoryNamePN (categoryID: Int, newName: String) {
		
		let query = "UPDATE \(categories) SET name = '\(newName)' WHERE categoryID = \(categoryID)"
		myDB.executeStatements(query)
		
		print("updateCatetoryName query: \(query)")
		
		let name = Notification.Name(myKeys.changeCategoryNameKey)
		
		NotificationCenter.default.post(name: name, object: self, userInfo: ["categoryID" : categoryID])
	}
	
	func assignCategoryPN (termID: Int, categoryID: Int) {
		let query = "INSERT INTO \(assignedCategories) ('termID', 'categoryID') VALUES (\(termID), \(categoryID))"
		myDB.executeStatements(query)
		
		// send out notification
		let data = ["termID" : termID, "categoryID" : categoryID]
		let name = Notification.Name(myKeys.assignCategoryKey)
		NotificationCenter.default.post(name: name, object: self, userInfo: data)
	}
	
	func unassignCategoryPN (termID: Int, categoryID: Int) {
		let query = "DELETE FROM \(assignedCategories) WHERE termID = \(termID) AND categoryID = \(categoryID)"
		myDB.executeStatements(query)
		

		// send out notification
		let data = ["termID" : termID, "categoryID" : categoryID]
		let name = Notification.Name(myKeys.unassignCategoryKey)
		NotificationCenter.default.post(name: name, object: self, userInfo: data)
	}
	
}

