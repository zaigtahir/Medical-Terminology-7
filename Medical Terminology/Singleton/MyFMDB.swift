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
        
        let utilities = Utilities ()
        let fileURL = utilities.copyFileIfNeeded(fileName: "Medical Terminology", fileExtension: "db")
        fmdb = FMDatabase(path: fileURL?.absoluteString)
        fmdb.open()
        
    }
}
