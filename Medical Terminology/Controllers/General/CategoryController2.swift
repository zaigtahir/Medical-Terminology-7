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
CategoryID's indicate if it's a standard or custom category
1: 			interpret as any standard category
2 - 999:		an ID belonging to a standard category
1000:		just a place holder id. don't use this
1001+ :		an ID belonging to a custom category
*/

// getting rid of "category type in db"
// category type can be a calculated value of the category object

class CategoryController2 {
	
	let categoriesTable = "categories2"	//categories table
	
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
	
	func getCurrentCategory () -> Category {
		let query = "SELECT * FROM \(categoriesTable) WHERE selected = 1"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return makeCategoryFromResultset(resultSet: resultSet)
		} else {
			print ("fatal error getting resultset in getSelectedCategory")
			return Category()
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
	
	func getCountFromCategoriesTable (whereStatment: String) -> Int {
		
		let query = "SELECT COUNT (*) FROM \(categoriesTable) \(whereStatment)"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return Int(resultSet.int(forColumnIndex: 0))
		} else {
			print("problem creating the resultSet in getCategoryCount")
			return 0
		}
	}
	
	func toggleCategorySelection (categoryID: Int) {
		// toggle the categories based on the user toggling the selection for this category
		// toggle rule: allow only one category selection
		
		guard let category = getCategory(categoryID: categoryID) else {
			print("fatal error: problem getting the category in toggleCategorySelection()")
			return
		}
		
		// if the category is already selected, do nothing
		if category.selected  {
			return
		}
		
		// use this to deselect all in preparation to set one as the selected one
		myDB.executeUpdate("UPDATE \(categoriesTable) SET selected = 0", withArgumentsIn: [])
		
		// now just set the one selected
		myDB.executeUpdate("UPDATE \(categoriesTable) SET selected = 1 WHERE categoryID = \(categoryID)", withArgumentsIn: [])
		
	}
	
	func changeCategoryName (categoryID: Int, nameTo: String) {
		myDB.executeUpdate("UPDATE \(categoriesTable) SET name = ? WHERE categoryID = ?", withArgumentsIn: [nameTo, categoryID])
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
		
		if let resultSet = myDB.executeQuery("SELECT MAX(displayOrder) FROM \(categoriesTable) WHERE categoryID >= 1000", withArgumentsIn: []) {
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
		
		let c = getCountFromCategoriesTable(whereStatment: "WHERE name == \"\(name)\" AND categoryID >= 1001")
		
		if c > 0 {
			return true
		} else {
			return false
		}
		
	}

	private func makeCategoryFromResultset (resultSet: FMResultSet) -> Category {
		
		let categoryID = Int(resultSet.int(forColumn: "categoryID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let description = resultSet.string(forColumn: "description") ?? ""
		let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
		let selected = Int(resultSet.int(forColumn: "selected"))
		
		var s = false
		if selected == 1 {
			s = true
		}
		
		let c = Category(categoryID: categoryID,
						 name: name,
						 description: description,
						 type: .standard,	//place holder entry
						 displayOrder: displayOrder,
						 selected: s
		)
		
		return c
	}
}
