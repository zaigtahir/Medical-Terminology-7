//
//  CategoryController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

/*
categoryID = 0: all standard categories, table = mainTerms
categoryID = 1-998: just that catetory, table = mainTerms
categoryID = 999: just a place holder
categoryID = >= 1000: jus that category, table = userCategoryTerms
*/

// getting rid of "category type in db"
// category type can be a calculated value of the category object

class CategoryController {
	
	let categoriesTable = myConstants.dbTableCatetories	//categories table
	
	let dIC = DItemController3()
	
	func isCategoryStandard (categoryID: Int) -> Bool {
		// will return true if this is a standard category id
		if categoryID < myConstants.dbCustomCategoryStartingID {
			return true
		} else {
			return false
		}
	}
	
	func getCategory (categoryID: Int) -> Category? {
		
		//if no category is found with this ID, return nil
		
		let query = "SELECT * from \(categoriesTable) WHERE categoryID = \(categoryID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: [categoryID]) {
			if resultSet.next() {
				return makeCategoryFromResultset(resultSet: resultSet)
			} else {
				return nil
			}
			
		} else {
			print("Fatal error getting the result set in getCategories function")
			return nil
		}
	}
	
	func getCategoryIDs (whereStatment: String) -> [Int] {
		
		//will return the id's of the category
		
		var categories = [Int]()
		
		let query = "SELECT categoryID FROM \(categoriesTable) \(whereStatment)"
		
		if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
			while resultSet.next() {
				let categoryID = Int(resultSet.int(forColumn: "categoryID"))
				categories.append(categoryID)
			}
			return categories
		} else {
			return categories
		}
		
	}
	
	func getCategories (categoryType: CategoryType) -> [Category] {
		
		var categories = [Category]()
		
		//note a null value in datatable returned as int is 0
		
		var query: String
		
		if categoryType == .standard {
			query = "SELECT * FROM \(categoriesTable) WHERE categoryID < \(myConstants.dbCustomCategoryStartingID - 1)"	//don't include the place holder category number
		} else {
			query = "SELECT * FROM \(categoriesTable) WHERE categoryID >= \(myConstants.dbCustomCategoryStartingID)"
		}
		
		if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
			
			while resultSet.next() {
				categories.append(makeCategoryFromResultset(resultSet: resultSet))
			}
			
		} else {
			
			print("Fatal error getting the result set in getCategories function")
		}
		
		return categories
		
	}
	
	func getItemCountInCategory(categoryID: Int) -> Int {
		
		var query: String
		
		
		if (categoryID == 0) {
			
			query = "SELECT COUNT (*) FROM \(myConstants.dbTableMain) WHERE categoryID != \(myConstants.dbCustomTermStartingID - 1)" }
		else if (categoryID < myConstants.dbCustomCategoryStartingID - 1 ) {
			query = "SELECT COUNT (*) FROM \(myConstants.dbTableMain) WHERE categoryID = \(categoryID)"
		} else {
			query = "SELECT COUNT (*) FROM \(myConstants.dbTableUser) WHERE categoryID = \(categoryID)"
		}
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []){
			resultSet.next()
			let count = Int(resultSet.int(forColumnIndex: 0))
			return count
			
		} else {
			print ("fatal error getting resultset in getItemCountInCategory")
			return 0
		}
	}
	
	func changeStandardCategory (categoryID: Int, itemID: Int) -> Bool {
		
		// Each item must have ONE standard category assigned. This function will
		
		if (categoryID == 0) {
			// not allowed to add/subtract from this Alias category
			return false
		}
		
		guard let category = getCategory(categoryID: categoryID) else {
			print("fatal error: problem getting the category changeStandardCategory")
			return false
		}
		
		let dItem = dIC.getDItem(itemID: itemID)
		
		if category.categoryID == dItem.categoryID {
			//this is already selected so don't do anything
			return false
		}
		
		// if here, change the category in the database
		let query = "UPDATE \(myConstants.dbTableMain) SET categoryID = \(categoryID) WHERE itemID = \(itemID)"
		
		myDB.executeStatements(query)
		
		return true
		
	}
	
	func changeCategoryName (categoryID: Int, nameTo: String) {
		myDB.executeUpdate("UPDATE \(categoriesTable) SET name = ? WHERE categoryID = ?", withArgumentsIn: [nameTo, categoryID])
	}
	
	/*
	will fill dItem with defaultCategoryID and also an array of custom categoryID's it is assigned if any
	*/
	
	func getItemDefaultCategoryID (itemID: Int) -> Int {
		
		let query = "SELECT defaultCategoryID FROM \(myConstants.dbTableMain) WHERE itemID = \(itemID)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			
			let categoryID = Int(resultSet.int(forColumnIndex: 0))
			return categoryID
			
		} else {
			print ("fatal error making resultset addCategoryIDs")
			return 0
		}
	}
	
	func getItemCustomCategoryIDs (itemID: Int) -> [Int] {
		
		var ids = [Int]()
		let query = "SELECT categoryID FROM \(myConstants.dbTableUser) WHERE itemID = \(itemID)"
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let i = Int (resultSet.int(forColumnIndex: 0))
				ids.append(i)
			}
			return ids
		} else {
			print ("fatal error making resultset addCategoryIDs")
			return ids
		}
	}
	
	func deleteCategory (categoryID: Int) {
		myDB.executeStatements("DELETE from \(categoriesTable) WHERE categoryID = \(categoryID)")
	}
	
	/*
	Will add a catetory. You must have a place holder category with id = 999 so any additional ones will get id's assigned higher than that with the database row numering
	*/
	func addCustomCategory (name: String) {
		//add a custom category
		
		// MARK: need to format string, check for duplicate names, assign view order
		
		//get the maximum number for displayOrder of custom categories
		
		var maxOrder = 0
		
		if let resultSet = myDB.executeQuery("SELECT MAX(displayOrder) FROM \(categoriesTable) WHERE categoryID >= \(myConstants.dbCustomCategoryStartingID)", withArgumentsIn: []) {
			resultSet.next()
			maxOrder = Int(resultSet.int(forColumnIndex: 0))
		} else {
			print("problem creating the resultSet in addCustomCategory")
		}
		
		let displayOrder = maxOrder + 1
		
		if isDevelopmentMode {
			print ("Adding custom category: \(name) with displayOrder: \(displayOrder)")
		}
		
		myDB.executeStatements("INSERT INTO \(categoriesTable) (name, description, displayOrder, selected) VALUES ('\(name)', 'new', \(displayOrder), 0)")
	}
	
	func customCatetoryNameIsUnique (name: String) -> Bool {
		// will check to see if ths name already exists as a custom category name
		// CaSe sensitive
		
		let query = "SELECT COUNT (*) FROM \(myConstants.dbTableCatetories) WHERE name == \"\(name)\" AND categoryID >= \(myConstants.dbCustomCategoryStartingID)"
		
		print("custom unique function: \(query)")
		
		if let resultSet =  myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			let count = Int(resultSet.int(forColumnIndex: 0))
			if count == 0 {
				return true
			} else {
				return false
			}
		} else {
			print ("fatal error getting resultSet in customCatetoryNameIsUnique")
			return false
		}
	}
	
	
	
	// MARK: Private functions
	
	private func makeCategoryFromResultset (resultSet: FMResultSet) -> Category {
		
		let categoryID = Int(resultSet.int(forColumn: "categoryID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let description = resultSet.string(forColumn: "description") ?? ""
		let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
		
		let c = Category(categoryID: categoryID,
						 name: name,
						 description: description,
						 displayOrder: displayOrder,
						 count: 0		// will need to update this when the program needs
		)
		
		return c
	}
}
