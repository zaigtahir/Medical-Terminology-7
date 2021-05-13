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
			
			if setupNewDatabase() {
				//update version settings only if no problems
				if sc.isDevelopmentMode() {
					print("new database is successfully setup, now will update the version in directory")
				}
				
				sc.updateVersionNumber()
				
			}
		
			return
		}
		
		if sc.getBundleVersion() == sc.getUserDefaultsVersion() {
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
	
	private func setupNewDatabase () -> Bool {
		// will copy the db from the bundle to the directory and open the database
		
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
		// Idea is to transfer the learned and answered settings from the current DB to the new DB
		// then delete the current DB and use the new DB as the default
		
		// my DItemController works on the global database so first lets create a list of id's and associated
		// need to open the current database to use so I can copy the presistent information from it
		
		
		print("to code migrateDatabase in DatabaseUtilities")
		
		useCurrentDatabase()
		
		
		
		
		
		/*
		
		let dIC = DItemController()
		let dItemsToMigrate = dIC.getDItemsMigrate()
		
		myDB.close()
		
		// delete the current database file
		let dbFileURL = getDirectoryFileURL(fileName: myConstants.dbFilename, fileExtension: myConstants.dbFileExtension)
		_ = deleteDirectoryFileAtURL(fileURL: dbFileURL)
		
		// copy the db file from bundle to make new db
		if setupNewDatabase() {
		
		//migrate the data
		dIC.saveDItemsMigrate(dItems: dItemsToMigrate)
		settingsC.updateVersionNumber()
		}
		
		*/
		
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
