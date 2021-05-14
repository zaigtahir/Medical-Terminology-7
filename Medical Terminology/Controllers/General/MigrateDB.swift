//
//  MigrateDB.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class MigrateDB {
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	let categories = myConstants.dbTableCategories
	
	let sc = SettingsController()
	
	
	func migrateDatabase () {
	
		if sc.isDevelopmentMode() {
			print("migrateDatabase function")
		}
		// get resultSetCustomTerms of all custom terms
		// get resultSetCustomCategories of all custom categories
		// get resultSet for assignedCategoriesBothCustom		 	where term = custom AND category = custom
		// get resultSet for assignedCategoriesCustomTermOnly		where term = custom AND catetory = not custom
		// get resultSet for assignedCategoriesCustomCategoryOnly	where term = not cusotm AND category = custom
		// close db
		// delete the db file
		
		// setup new db... all terms, categories and assignCategory entries will be made for the standard terms and standard categories
		
		// insert custom terms in Terms
		// insert custom categories in Categories
		// insert additional assignedCategories for custom terms and custom categories
		
		let rsCustomTerms  = resultSetCustomTerms()
		let rsCustomCategories = resultSetCustomCategories()
		let rsACBothCustom = resultSetAssignedCategoriesBothCustom()
		let rsACTermsCustom = resultSetAssignedCategoriesTermsCustom()
		let rsACCategoriesCustom = resultSetAssignedCategoriesCategoriesCustom()
		
		if sc.isDevelopmentMode() {
			print("migrateDatabase: made backup resultSets")
			print("migrateDatabase: closing and deleting the original db")
		}
		
		myDB.close()
		
		
		
	}
	
	// MARK: - migrate resultSets
	private func resultSetCustomTerms () -> FMResultSet? {
		let query = "SELECT * FROM \(terms) WHERE termID >= \(myConstants.dbCustomTermStartingID)"
		let resultSet = myDB.executeQuery(query, withArgumentsIn: [])
		return resultSet
	}
	
	private func resultSetCustomCategories () -> FMResultSet?  {
		let query = "SELECT * FROM \(categories) WHERE categoryID >= \(myConstants.dbCustomCategoryStartingID)"
		let resultSet = myDB.executeQuery(query, withArgumentsIn: [])
		return resultSet
	}
	
	private func resultSetAssignedCategoriesBothCustom () -> FMResultSet? {
		let query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) AND categoryID >= \(myConstants.dbCustomCategoryStartingID))"
		let resultSet = myDB.executeQuery(query, withArgumentsIn: [])
		return resultSet
	}
	
	private func resultSetAssignedCategoriesTermsCustom ()  -> FMResultSet?  {
		let query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) AND categoryID < \(myConstants.dbCustomCategoryStartingID))"
		let resultSet = myDB.executeQuery(query, withArgumentsIn: [])
		return resultSet
	}
	
	private func resultSetAssignedCategoriesCategoriesCustom ()  -> FMResultSet?  {
		let query = "SELECT * FROM \(assignedCategories) WHERE (termID < \(myConstants.dbCustomTermStartingID) AND categoryID >= \(myConstants.dbCustomCategoryStartingID))"
		let resultSet = myDB.executeQuery(query, withArgumentsIn: [])
		return resultSet
	}
	
	
}
