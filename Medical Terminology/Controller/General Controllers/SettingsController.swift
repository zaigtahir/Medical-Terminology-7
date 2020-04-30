//
//  SettingsController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/30/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

class SettingsController {
    
    func getSettings () -> Settings {
        
        let settings = Settings()
        settings.showIntro = 444
        
        let query = "Select * from settings WHERE settingID = 0"
        
        if let resultSet = myFMDB.fmdb.executeQuery(query, withParameterDictionary: nil) {
            
            let column = resultSet.columnCount
            for i in 0...column - 1 {
                let name = resultSet.columnName(for: i)
                print (name)
            }
            //there will only be a single result
            resultSet.next()
            
            settings.showIntro = Int(resultSet.int(forColumn: "showIntro"))
            return settings
            
        } else {
            print("problem getting the settings object from the database, returning a new initialized Settings objecdt")
            
            return settings
        }
        
    }
   
    
}
