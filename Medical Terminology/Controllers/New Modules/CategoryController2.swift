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
	
	func getCategoryID (mainSectionName: MainSectionName) -> Int {
		
		let query = "SELECT categoryID FROM \(mainSectionCategories) WHERE sectionName = '\(mainSectionName.rawValue)' "
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []){
			resultSet.next()
			let id = Int(resultSet.int(forColumnIndex: 0))
			return id
		} else {
			print ("fatal error getting rs in getMainSectionCategoryID, returning 0")
			return 0
		}
		
	}
	
	func setCategoryID (mainSectionName: MainSectionName, categoryID: Int) {
		myDB.executeUpdate("UPDATE \(mainSectionCategories) SET categoryID = ? WHERE sectionName = ?", withArgumentsIn: [categoryID, mainSectionName.rawValue ])
	}
	
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
			query = "SELECT * from \(categories) WHERE isCustom = \(categoryType.rawValue) ORDER BY displayOrder"
		} else {
			query = "SELECT * from \(categories) WHERE isCustom = \(categoryType.rawValue) ORDER BY displayOrder"
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
		
		
		/*
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let c = fillCategory(resultSet: resultSet)
				categories.append(c)
			} else {
				print("fatal error did not find category with id = \(categoryID) in getCategory. Returning empty category")
				return Category2()
			}
			
		} else {
			print("Fatal error getting the result set in getCategories function")
			return Category2()
		}
		*/
	}
	
	private func fillCategory (resultSet: FMResultSet) -> Category2 {
		
		let categoryID = Int(resultSet.int(forColumn: "categoryID"))
		let name = resultSet.string(forColumn: "name") ?? ""
		let description = resultSet.string(forColumn: "description") ?? ""
		let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
		let isCustom = Int(resultSet.int(forColumn: "isCustom"))
		
		let c = Category2(categoryID: categoryID,
						 name: name,
						 description: description,
						 displayOrder: displayOrder,
						 isCustom: isCustom == 1 ? true : false,
						 count: 0		// will need to update this when the program needs
		)
		
		return c
	}
	
}
