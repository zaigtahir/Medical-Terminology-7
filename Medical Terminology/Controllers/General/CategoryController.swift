//
//  CategoryController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/24/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class CategoryController {
	
	// to make the table name shorter and convenient
	let categories =  myConstants.dbTableCategories
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	// controllers
	
	func getCategory (categoryID: Int) -> Category {
		
		let query = "SELECT * from \(categories) WHERE categoryID = \(categoryID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: [categoryID]) {
			if resultSet.next() {
				return fillCategory(resultSet: resultSet)
			} else {
				print("fatal error did not find category with id = \(categoryID) in getCategory. Returning empty category")
				return Category()
			}
			
		} else {
			print("Fatal error getting the result set in getCategories function")
			return Category()
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
	func getCategories (categoryType: CategoryType) -> [Category] {
		
		var query: String
		var cs = [Category]()
		
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
	Update the categories just locally in the term, and nothing is saved to the DB. The categories are sorted.
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
			
			// sort the categories to the usual order
			sortAssignedCategories(term: term)
			
			// send out notification
			let data = ["termID" : term.termID, "categoryID" : categoryID]
			let name = Notification.Name(myKeys.assignCategoryKey)
			NotificationCenter.default.post(name: name, object: self, userInfo: data)
		}
	
	}

	/**
	Use this to sort the categories in a new term as they are no retrived from the db in my ususual order
	*/
	func sortAssignedCategories (term: Term) {
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
		
		
		// attaching the ordered list to the array
		term.assignedCategories = orderedArray
		
	}
	
	func addCategoryPN (category: Category) {
		
		// the new category will be added with custom catetory display order = 1, so need to increment all custom category display order by 1
		
		let query = "UPDATE \(categories) SET displayOrder = displayOrder  + 1 WHERE isStandard = 0"
		
		myDB.executeStatements(query)
		
		let queryInsert = "INSERT INTO \(categories) (name, description, displayOrder, isStandard) VALUES ('\(category.name)', '\(category.description)', 1, 0)"
		
		myDB.executeStatements(queryInsert)
		
		let nName = Notification.Name(myKeys.addCategoryKey)
		NotificationCenter.default.post(name: nName, object: self, userInfo: nil)
		
	}
	
	private func fillCategory (resultSet: FMResultSet) -> Category {
		let categoryID = Int(resultSet.int(forColumn: "categoryID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let description = resultSet.string(forColumn: "description") ?? ""
		let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
		let isStandard = Int(resultSet.int(forColumn: "isStandard"))
		
		let c = Category (categoryID: categoryID,
						   name: name,
						   description: description,
						   displayOrder: displayOrder,
						   isStandard: isStandard == 1 ? true : false,
						   count: 0		// will need to update this when the program needs
		)
		
		return c
	}
	
	func categoryNameIsUnique (name: String, notIncludingCategoryID: Int) -> Bool {
		let query = "SELECT COUNT (*) FROM \(categories) WHERE name LIKE '\(name)' AND categoryID != \(notIncludingCategoryID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let count = Int (resultSet.int(forColumnIndex: 0))
			
			if count > 0 {
				return false
			} else {
				return true
			}
			
		} else {
			print("fatal error making RS in categoryNameIsUnique. returning false as safety default")
			return false
		}
	}
	
	// MARK: - Functions that send off program wide notifications
	
	func addCategoryPN (categoryName: String) {
		// if duplicate name do not add it
		// always add with display order = 1
		// shift display order of other custom categories up by 1 to make room
		// return true on success
		// return false on not successful
		
		let moveQuery = "UPDATE \(myConstants.dbTableCategories) SET displayOrder = displayOrder + 1 WHERE isStandard = 0"
		
		let _ = myDB.executeStatements(moveQuery)
		
		let addQuery = "INSERT INTO \(myConstants.dbTableCategories) (name, description, isStandard, displayOrder) VALUES ('\(categoryName)', 'initial description', 0, 1)"
		
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
	
	func updateCategoryDescription (categoryID: Int, description: String) {
		let query = "UPDATE \(categories) SET description = '\(description)' WHERE categoryID = \(categoryID)"
		
		myDB.executeStatements(query)
	}
	
	func updateCategoryNamePN (categoryID: Int, newName: String) {
		
		let query = "UPDATE \(categories) SET name = '\(newName)' WHERE categoryID = \(categoryID)"
		myDB.executeStatements(query)
	
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

