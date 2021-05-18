//
//  DatabaseUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 2/27/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

// MARK: DO THESE NEED TO BE GLOBAL?

class DatabaseUtilities  {
	
	let fileManager = FileManager()
	let sc = SettingsController()
	let tc = TermController()
	let cc = CategoryController()
	let ac = AssignedCategoryController()
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	let categories = myConstants.dbTableCategories
	
	// MARK: -install database functions
	func setupDatabase () {
		//will look at the versions and copy, migrate or use the existing database
		
		if sc.getUserDefaultsVersion() == "-1.-1" {
			// new install
			if sc.isDevelopmentMode() {
				print("new install: copy over the database into the directory")
			}
			
			if installDatabase() {
				//update version settings only if no problems
				if sc.isDevelopmentMode() {
					print("new database is successfully setup, now will update the version in directory")
				}
				
				sc.updateVersionNumber()
				
			}
			
		} else if sc.getBundleVersion() == sc.getUserDefaultsVersion() {
			// use current database
			if sc.isDevelopmentMode() {
				print("normal run: no changes to database")
			}
			useCurrentDatabase()
			
		} else {
			// migrate database
			if sc.isDevelopmentMode() {
				print("update: need to migrate the database")
			}
			
			migrateDb()
			
			//MARK: check no error migrating the db before updating the version
		}
		
	}
	
	/**
	Will close the db if open
	Will delete the db file from the directory
	Will copy the db file from the bundle to the directory
	Will insert rows in assignedCategories table to assign categories to each term (1, secondCategoryID, thirdCategoryID)
	*/
	func installDatabase () -> Bool {
		
		/**
		Will return ARRAY of [termID, secondCategoryID, thirdCategoryID]
		*/
		func getTermInstallationCategories () -> [[Int]]{
			
			var ids = [[Int]]()
			
			let query = "SELECT termID, secondCategoryID, thirdCategoryID FROM \(terms) WHERE termID < \(myConstants.dbCustomTermStartingID)"
			
			if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
				while resultSet.next() {
					let termID = Int(resultSet.int(forColumnIndex: 0))
					let secondCategoryID = Int(resultSet.int(forColumnIndex: 1))
					let thirdCategoryID = Int(resultSet.int(forColumnIndex: 2))
					
					let termCategoryIDs = [termID, secondCategoryID, thirdCategoryID]
					
					ids.append(termCategoryIDs)
				}
				
			} else {
				print ("fatal error making rs in getTermInstallationCategories, returning empty [Int]")
			}
			
			return ids
		}
		
		/**
		Will use an array of  [termID, secondCategoryID, thirdCategoryID]
		add category = 1 and the other 2 category IDs to each termID  in the assignedCategories table
		*/
		func installTermsToAssignedCategories (termCategoryArray: [[Int]]) {
			
			if sc.isDevelopmentMode(){
				print("in - installTermsToAssignedCategories")
			}
			
			for s in termCategoryArray {
				
				// add to term to categoryID 1
				let query = "INSERT INTO \(assignedCategories) (termID, categoryID) VALUES ('\(s[0] )', 1)"
				myDB.executeStatements(query)
				
				if s[1] != 0 {
					let query = "INSERT INTO \(assignedCategories) (termID, categoryID) VALUES ('\(s[0] )', \(s[1]))"
					myDB.executeStatements(query)
				}
				
				if s[2] != 0 {
					let query = "INSERT INTO \(assignedCategories) (termID, categoryID) VALUES ('\(s[0] )', \(s[2]))"
					myDB.executeStatements(query)
				}
			}
		}
		
		guard let dbURL = copyFile(fileName: myConstants.dbFilename, fileExtension: myConstants.dbFileExtension) else {
			//error copying the db
			print("FATAL error was an error copying the db to directory")
			//MARK: to do setup a graceful exit/notice to user
			return false
		}
		
		if sc.isDevelopmentMode() {
			print("in setupNewDatabase")
			print ("dbURL = \(dbURL)")
		}
		
		myDB = FMDatabase(path: dbURL.absoluteString)
		myDB.open()
		
		// Install terms to assigned categories
		let termArrays = getTermInstallationCategories()
		
		installTermsToAssignedCategories(termCategoryArray: termArrays)
		
		return true
	}
	
	private func migrateDb () {
		/*
		Restore custom terms
		Restore custom categories
		Restore assignedCategories for custom terms and categories, keeping in mind that a standard category or standard term may not exist
		in the updated database. In that case, no assignedCategory entry is made
		*/
		
		if sc.isDevelopmentMode() {
			print("In migrateDB function")
		}
		
		// variables for back up of custom data
		var customTerms = [Term] ()
		var customCategories = [Category] ()
		var assignedCategoriesCustom = [AssignedCategory]()
		
		func backupCustomData () {
			
			if sc.isDevelopmentMode() {
				print("in backupCustomData")
			}
			
			// custom terms
			var query = "SELECT * FROM \(terms) WHERE termID >= \(myConstants.dbCustomTermStartingID)"
			if let rsCustomTerms = myDB.executeQuery(query, withArgumentsIn: []) {
				while rsCustomTerms.next() {
					customTerms.append(tc.getTermFromResultSet(resultSet: rsCustomTerms))
				}
			}
			
			// custom categories
			query = "SELECT * FROM \(categories) WHERE categoryID >= \(myConstants.dbCustomCategoryStartingID)"
			if let rsCustomCategories = myDB.executeQuery(query, withArgumentsIn: []) {
				while rsCustomCategories.next() {
					customCategories.append(cc.getCategoryFromResultSet(resultSet: rsCustomCategories))
				}
			}
			
			// assignedCategories with either or both are custom items
			query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) OR categoryID >= \(myConstants.dbCustomCategoryStartingID))"
			
			if let rsACCustom = myDB.executeQuery(query, withArgumentsIn: []){
				while rsACCustom.next() {
					assignedCategoriesCustom.append(ac.getAssignedCategoryFromResultSet(resultSet: rsACCustom))
				}
			}
		}
		
		func restoreCustomData () {
			
			if sc.isDevelopmentMode() {
				print("restoreCustomData")
			}
			
			for term in customTerms {
				tc.saveTermForMigration(term: term)
			}
			
			for category in customCategories {
				cc.saveCategoryForMigration(category: category)
			}
			
			// restore the assigned category as long as BOTH the termID and the categoryID exist
			for assignedCategory in assignedCategoriesCustom {
				if tc.termExists(termID: assignedCategory.termID) && cc.categoryExists(categoryID: assignedCategory.categoryID) {
					ac.saveAssignedCategoryForMigration(assignedCategory: assignedCategory)
				}
				
			}
			
		}
		
		useCurrentDatabase()
		
		backupCustomData()
		
		myDB.close()
		
		let _ = installDatabase()
		
		restoreCustomData()
		
		sc.updateVersionNumber()
		
	}
	
	private func useCurrentDatabase () {
		
		if sc.isDevelopmentMode(){
			print("in useCurrentDatabase()")
		}
		
		let dbURL = getDirectoryFileURL(fileName: myConstants.dbFilename, fileExtension: myConstants.dbFileExtension)
		
		if sc.isDevelopmentMode() {
			print("current db path: \(dbURL.absoluteString)")
		}
		
		myDB = FMDatabase(path: dbURL.absoluteString)
		myDB.open()
	}
	
	// MARK: - file functions
	
	private func copyFile (fileName: String, fileExtension: String) -> URL?{
		
		let sourceURL = getBundleFileURL(fileName: fileName, fileExtension: fileExtension)
		let destinationURL = getDirectoryFileURL(fileName: fileName, fileExtension: fileExtension)
		
		_ = deleteDirectoryFileAtURL(fileURL: destinationURL)
		
		if let sURL = sourceURL {
			do {
				try fileManager.copyItem(at: sURL, to: destinationURL)
				
			} catch let error as NSError {
				print("Could not copy the database to Directorys folder. Error: \(error.description)")
				return nil
			}
		}
		
		return destinationURL
	}
	
	private func deleteDirectoryFileAtURL (fileURL: URL) -> Bool {
		// if the file exists, will delete it
		// Return true if deleted or does not exist, return false if there was an error
		
		if fileManager.fileExists(atPath: fileURL.path) {
			//file exists and will delete it
			do {
				try fileManager.removeItem(at: fileURL)
				return true
			} catch let error as NSError {
				print("There was an error deleting the file: \(error.description)")
				return false
			}
		} else {
			return true // file does not exist so no error state
		}
	}
	
	private func getBundleFileURL (fileName: String, fileExtension: String) -> URL? {
		return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
	}
	
	private func getDirectoryFileURL (fileName: String, fileExtension: String) -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentDirectoryURL = paths[0]
		let url = documentDirectoryURL.appendingPathComponent("\(fileName).\(fileExtension)")
		return url
	}
}
