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
}
