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
used to manage categories
categoryType = 0	standard, built in
categoryType = 1	custom
*/


class CategoryController {
	
	func getCategory (categoryID: Int) -> Category? {
		
		//if no category is found with this ID, return nil
		
		let query = "SELECT * from categories WHERE categoryID = \(categoryID)"
		
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
	
	func getCategories (categoryType: Int) -> [Category] {
		
		var categories = [Category]()
		
		//note a null value in datatable returned as int is 0
		
		let query = "SELECT * FROM categories WHERE type = \(categoryType)"
		
		if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
			
			while resultSet.next() {
				categories.append(makeCategoryFromResultset(resultSet: resultSet))
			}
			
		} else {
			
			print("Fatal error getting the result set in getCategories function")
		}
		
		return categories
		
	}
	
	func getCategoryIDs (whereStatment: String) -> [Int] {
		
		//will return the id's of the category
		
		var categories = [Int]()
		
		let query = "SELECT categoryID FROM categories \(whereStatment)"
		
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
	
	func getCategoryCount (whereStatment: String) -> Int {
		
		let query = "SELECT COUNT (*) FROM categories \(whereStatment)"
		
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
		myDB.executeUpdate("UPDATE categories SET selected = 0", withArgumentsIn: [])
		
		// now just set the one selected
		myDB.executeUpdate("UPDATE categories SET selected = 1 WHERE categoryID = \(categoryID)", withArgumentsIn: [])
		
	}
	
	func addCustomCategoryName (name: String) {
		//add a custom category
	
		myDB.executeStatements("INSERT INTO categories (name, description, type, displayOrder, selected) VALUES ('\(name)', 'new category', 1, 15, 0)")
	}
	
	private func makeCategoryFromResultset (resultSet: FMResultSet) -> Category {
		
		let categoryID = Int(resultSet.int(forColumn: "categoryID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let description = resultSet.string(forColumn: "description") ?? ""
		let type = Int(resultSet.int(forColumn: "type"))
		let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
		let selected = Int(resultSet.int(forColumn: "selected"))
		
		var s = false
		if selected == 1 {
			s = true
		}
		
		let c = Category(categoryID: categoryID,
						 name: name,
						 description: description,
						 type: type,
						 displayOrder: displayOrder,
						 selected: s
		)
		
		return c
	}
	
}
