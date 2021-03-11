//
//  CategoryController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

//used to manage categories
class CategoryController {
	
	var categories = [Category]()
	
	/*
	Return a collection of categories from the database
	categoryType = 0	standard, built in
	categoryType = 1	custom
	*/
	func getCategories (categoryType: Int) -> [Category] {
		
		var categories = [Category]()
		
		//note a null value in datatable returned as int is 0
		
		let query = "SELECT * FROM categories WHERE type = \(categoryType)"
		
		if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
			
			while resultSet.next() {
				
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
				
				categories.append(c)
			}
			
		} else {
			// error state: no categories found
			// MARK: do some thing here
			
			if isDevelopmentMode {
				print("Fatal error getting the result set in getCategories function")
			}
		}
		
		return categories
		
	}
	
	func getCategoryIDs(categoryType : Int) -> [Int] {
		//will return the id's of the category
		
		var categories = [Int]()
		
		let query = "SELECT categoryID FROM categories WHERE type = \(categoryType)"
		
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
	
	func toggleCategorySelection (selectedCategoryID : Int) {
		
		// if categoryType = 0 (standard) select it, deselect 1
		// if categoryType = 1 (custom) select it, deselect all other
		
		let standardCategoryIDs = getCategoryIDs(categoryType: 0)
		let customCategoryIDs = getCategoryIDs(categoryType: 1)
		
		if selectedCategoryID == 1 {
			// if categoryID = 1, select that and deselect all others
			for categoryID in standardCategoryIDs {
				saveCategorySelected(categoryID: categoryID, selected: false)
			}
			
			for categoryID in customCategoryIDs {
				saveCategorySelected(categoryID: categoryID, selected: false)
			}
			
			saveCategorySelected(categoryID: 1, selected: true)
		}
		
	}
	
	private func saveCategorySelected (categoryID: Int, selected: Bool) {
		var s = 0
		if selected {
			s = 1
		}
		myDB.executeUpdate("UPDATE categories SET selected = ? WHERE categoryID = ?", withArgumentsIn: [s, categoryID])
	}
}
