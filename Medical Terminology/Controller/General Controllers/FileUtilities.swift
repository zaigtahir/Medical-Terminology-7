//
//  FileUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/3/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation

class FileUtilities {
    
    func copyFileIfNeeded (fileName: String, fileExtension: String) -> URL? {
        //will copy a file from the resource bundle to the document directory if it is already not there and return a URL to it
        //will be using this function to copy the database file file to teh document directory when the app is first run after installation
        
        let fileManager = FileManager()
        
        //if the file does not exist in the resource bundle, return nill
        guard let bundleFileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print ("bundleFileURL not found in Utilities")
            return nil
        }
        
        //make url to the file in the document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = paths[0]
        let documentURL = documentDirectoryURL.appendingPathComponent("\(fileName).\(fileExtension)")
        
        //if the file already exists in the document directory, just return it's URL
        if fileManager.fileExists(atPath: documentURL.path) {
            return documentURL
        } else {
            //file DOES NOT exist in the document directory. copy it there from the resource bundle and return it's URL
            do {
                try fileManager.copyItem(at: bundleFileURL, to: documentURL)
                print("copied the database to documents folder")
                return documentURL
            } catch let error as NSError {
                print("Could not copy the database to documents folder. Error: \(error.description)")
                return nil
            }
        }
    }
    
    //MARK:- Older functions
    
    func deleteFileInDocumentDirectory (fileName: String, fileExtension: String) {
           
           
           let fileManager = FileManager()
           
           //make a path in the documents directory
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           
           let documentDirectoryURL = paths[0]
           
           let newURL = documentDirectoryURL.appendingPathComponent("\(fileName).\(fileExtension)")
           
           if fileManager.fileExists(atPath: newURL.path) {
               
               print("yes file exists!")
               
           } else {
               
               print("no file does NOT exist")
           }
           
       }
       
       func fileExistsInDocumentDirectory (fileName: String, fileExtension: String) -> Bool {
           
           let fileManager = FileManager()
           
           //make a path in the documents directory
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           let documentDirectoryURL = paths[0]
           let newURL = documentDirectoryURL.appendingPathComponent("\(fileName).\(fileExtension)")
           
           if fileManager.fileExists(atPath: newURL.path) {
               return true
           } else {
               return false
           }
       }
       
       func copyFileToDocumentsDirectory (fileName: String, fileExtension: String) -> URL? {
           // will copy a file from the resource bundle to the document directory and return a URL to it
           
           let fileManager = FileManager()
           
           //get url to db file in the bundle
           guard let bundleFileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
               print ("bundleFileURL not found in Utilities")
               return nil
           }
           
           //make a path in the documents directory
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           let documentDirectoryURL = paths[0]
           
           let newURL = documentDirectoryURL.appendingPathComponent("\(fileName).\(fileExtension)")
           
           
           if fileManager.fileExists(atPath: newURL.path) {
               print("in copy function: YES file exists, will need to delete it first before copying")
               do {
                   try fileManager.removeItem(at: newURL)
                   print("deleted the file")
               } catch let error as NSError {
                   print("There was an error deleting the file: \(error.description)")
               }
           } else {
               print("in copy function: no file does NOT exist")
           }
           
           
           do {
               try fileManager.copyItem(at: bundleFileURL, to: newURL)
               print("copied the database to documents folder")
               return newURL
           } catch let error as NSError {
               print("Could not copy the database to documents folder. Error: \(error.description)")
           }
           
           return newURL
           
       }
       

}
