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
	
	// MARK: controllers
	let sc = SettingsController()
	let du = DatabaseUtilities()
	
	// MARK: RecordSet variables
	var rsCustomTerms : FMResultSet?
	var rsCustomCategories : FMResultSet?
	var rsACBoth : FMResultSet?
	var rsACTerms : FMResultSet?
	var rsACCategories : FMResultSet?
	
	init () {
		
		makeBackupRecordSets()
		myDB.close()
		_ = du.installDatabase()
		
		
		
		
		
		
		
	}
	
	private func makeBackupRecordSets() {
		// custom terms
		var query = "SELECT * FROM \(terms) WHERE termID >= \(myConstants.dbCustomTermStartingID)"
		rsCustomTerms = myDB.executeQuery(query, withArgumentsIn: [])
		
		// custom categories
		query = "SELECT * FROM \(categories) WHERE categoryID >= \(myConstants.dbCustomCategoryStartingID)"
		rsCustomCategories = myDB.executeQuery(query, withArgumentsIn: [])
		
		// assigned categories custom term AND category
		query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) AND categoryID >= \(myConstants.dbCustomCategoryStartingID))"
		rsACBoth = myDB.executeQuery(query, withArgumentsIn: [])
		
		// assigned categories custom term only
		query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) AND categoryID < \(myConstants.dbCustomCategoryStartingID))"
		rsACTerms = myDB.executeQuery(query, withArgumentsIn: [])
		
		// assigned category custom category only
		query = "SELECT * FROM \(assignedCategories) WHERE (termID < \(myConstants.dbCustomTermStartingID) AND categoryID >= \(myConstants.dbCustomCategoryStartingID))"
		rsACCategories = myDB.executeQuery(query, withArgumentsIn: [])
	}
	
	
	
	
	
}
