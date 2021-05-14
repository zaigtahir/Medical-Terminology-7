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
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	let categories = myConstants.dbTableCategories
	
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
			
			migrateDatabase()
			
			//MARK: check no error migrating the db before updating the version
		}
		
	}
	
	/**
	Will close the db if open
	Will delete the db file from the directory
	Will copy the db file from the bundle to the directory
	Will insert rows in assignedCategories table to assign categories to each term (1, secondCategoryID, thirdCategoryID)
	*/
	private func installDatabase () -> Bool {
		
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
		
		installTermsToAssignCategories(termCategoryArray: termArrays)
		
		return true
	}
	
	private func migrateDatabase () {
		
		// MARK: Make backup of the data I will need to migrate in resultSets
		
		// custom terms
		var query = "SELECT * FROM \(terms) WHERE termID >= \(myConstants.dbCustomTermStartingID)"
		let rsCustomTerms = myDB.executeQuery(query, withArgumentsIn: [])
		
		// custom categories
		query = "SELECT * FROM \(categories) WHERE categoryID >= \(myConstants.dbCustomCategoryStartingID)"
		let rsCustomCategories = myDB.executeQuery(query, withArgumentsIn: [])
		
		// assigned categories custom term AND category
		query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) AND categoryID >= \(myConstants.dbCustomCategoryStartingID))"
		let rsACBoth = myDB.executeQuery(query, withArgumentsIn: [])
		
		// assigned categories custom term only
		query = "SELECT * FROM \(assignedCategories) WHERE (termID >= \(myConstants.dbCustomTermStartingID) AND categoryID < \(myConstants.dbCustomCategoryStartingID))"
		let rsACTerms = myDB.executeQuery(query, withArgumentsIn: [])
		
		// assigned category custom category only
		query = "SELECT * FROM \(assignedCategories) WHERE (termID < \(myConstants.dbCustomTermStartingID) AND categoryID >= \(myConstants.dbCustomCategoryStartingID))"
		let rsACCategories = myDB.executeQuery(query, withArgumentsIn: [])
		
		// MARK: close the database
		myDB.close()
		
		// MARK: Install the database
		installDatabase()
		
		
		print("working on migrate db class")
		useCurrentDatabase()
		
	}
	
	private func addTerms (resultSet: FMResultSet) {
		// add terms from this rs to the terms table
		while resultSet.next() {
			
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	private func useCurrentDatabase () {
		let dbURL = getDirectoryFileURL(fileName: myConstants.dbFilename, fileExtension: myConstants.dbFileExtension)
		
		if sc.isDevelopmentMode() {
			print("current db path: \(dbURL.absoluteString)")
		}
		
		myDB = FMDatabase(path: dbURL.absoluteString)
		myDB.open()
	}
	
	// MARK: - setting up database functions
	
	/**
	Will return an array of categores: 1, secondCategoryID, thirdCategoryID from the Terms table for STANDARD TERMS ONLY
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
				
				print("got from term table termID: \(termID ), \(secondCategoryID), \(thirdCategoryID)")
				
				ids.append(termCategoryIDs)
			}
			
		} else {
			print ("fatal error making rs in getTermInstallationCategories, returning empty [Int]")
		}
		
		return ids
	}
	
	/**
	Will return ARRAY of [termID, secondCategoryID, thirdCategoryID] and add each item to the assigned array
	*/
	func installTermsToAssignCategories (termCategoryArray: [[Int]]) {
		
		for s in termCategoryArray {
			
			print("adding to assigned categories termID: \(s[0] ), \(s[1]), \(s[2])")
			
			
			
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
