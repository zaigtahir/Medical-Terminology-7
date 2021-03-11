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
		
		guard let category = getCategory(categoryID: categoryID) else {
			print("fatal error: problem getting the category in toggleCategorySelection()")
			return
		}
		
		// if the user selected categoryID = 1: show all standard categories
		
		if category.categoryID == 1 {
			// user selected show all standard categories
			// if it's already selected then do nothing
			// if not selected, select only this one
			if category.selected ==  true {
				return
			} else {
				deselectAllCategories()
				saveCategorySelected(categoryID: category.categoryID, selected: true)
				return
			}
		}
		
		// if the user selected anything in the custom category, just select that one
		if category.type == 1 {
			//if it's alread selected do nothing
			if category.selected == true {
				return
			} else {
				deselectAllCategories()
				saveCategorySelected(categoryID: category.categoryID, selected: true)
				return
			}
		}
		
		// if here, the user pressed on selected a standard category that is not 1
		// if this category is already on AND the only one on, then dont do anything
		// if this category is NOT alread on, turn it on, turn off any custom ones
		//		now if all the standard categories are on, turn them all off and just keep 1 on
		
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
	
	private func saveCategorySelected (categoryID: Int, selected: Bool) {
		var s = 0
		if selected {
			s = 1
		}
		myDB.executeUpdate("UPDATE categories SET selected = ? WHERE categoryID = ?", withArgumentsIn: [s, categoryID])
	}
	
	private func deselectAllCategories () {
		//use this to deselect all in preparation to set one as the selected one
		myDB.executeUpdate("UPDATE categories SET selected = 0", withArgumentsIn: [])
	}
}
