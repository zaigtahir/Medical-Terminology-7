//
//  DatabaseUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 2/27/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

let fileManager = FileManager()

class DatabaseUtilities  {
    
    func setupDatabase () {
        //will look at the versions and copy, migrate or use the existing database
        
        let settingsC = SettingsController()
        
        if settingsC.getUserDefaultsVersion() == "0.0" {
            // new install
            _ = setupNewDatabase()
            settingsC.updateVersionNumber()
        }
        
        if settingsC.getBundleVersion() == settingsC.getUserDefaultsVersion() {
            // use current database
            useCurrentDatabase()
            
        } else {
            // migrate database
            settingsC.updateVersionNumber()
            migrateDatabase()
        }
        
    }
    
    private func setupNewDatabase () -> Bool {
    //will copy the db from the bundle to the directory and open the database
    
    guard let dbURL = copyFile(fileName: dbFilename, fileExtension: dbFileExtension) else {
        //error copying the db
        print("there was an error copying the db to directory")
        return false
    }
    
    myDB = FMDatabase(path: dbURL.absoluteString)
    myDB.open()
    print("copied the db to directory")
    return true
}
    
    private func migrateDatabase () {
        //MARK: add code for migration of the database
       
        // Idea is to transfer the learned and answered settings from the current DB to the new DB
        // then delete the current DB and use the new DB as the default
        
        // my DItemController works on the global database so first lets create a list of id's and associated
        
        let dIC = DItemController()
        let dItemsToMigrate = dIC.getDItemsMigrate()
        
        // close the current database and delete the file
        myDB.close()
        
        // delete the current database file
        let dbFileURL = getDirectoryFileURL(fileName: dbFilename, fileExtension: dbFileExtension)
        _ = deleteDirectoryFileAtURL(fileURL: dbFileURL)
        
        // copy the db file from bundle to make new db
        _ = setupNewDatabase()
        
        //migrate the data
        dIC.saveDItemsMigrate(dItems: dItemsToMigrate)
        
        print ("new database is implemented and the data is migrated!!!!")
        
    }
    
    private func useCurrentDatabase () {
        let dbURL = getDirectoryFileURL(fileName: dbFilename, fileExtension: dbFileExtension)
        myDB = FMDatabase(path: dbURL.absoluteString)
        myDB.open()        
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
