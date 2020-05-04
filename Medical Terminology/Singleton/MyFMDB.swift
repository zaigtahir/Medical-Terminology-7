//
//  MyFMDB.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

class MyFMDB {
    //will create a fmdb object
    
    var fmdb: FMDatabase!
    
    init() {
        
        let fU = FileUtilities ()
        
        //check to see if the database file already exists in the document directory
        
        //let fileURL = utilities.copyFileToDocumentsDirectory(fileName: "Medical Terminology", fileExtension: "db")
        
        let fileURL = fU.copyFileIfNeeded(fileName: "Medical Terminology", fileExtension: "db")
    
        fmdb = FMDatabase(path: fileURL?.absoluteString)
        
        fmdb.open()
        
    }
}
