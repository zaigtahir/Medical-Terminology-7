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
        settings.showWelcomeScreen = 444
        
        let query = "Select * from settings WHERE settingID = 0"
        
        if let resultSet = myFMDB.fmdb.executeQuery(query, withParameterDictionary: nil) {
    
            //there will only be a single result
            resultSet.next()
            
            settings.showWelcomeScreen = Int(resultSet.int(forColumn: "showWelcome"))
            
            return settings
            
        } else {
            print("problem getting the settings object from the database, returning a new initialized Settings object")
            
            return settings
        }
        
    }
    
    func saveShowWelcomeScreen (showIntro: Int) {
        //save the value in the database (remember only to save 0 or 1)
        
        myFMDB.fmdb.executeUpdate("UPDATE settings SET showWelcome = ? where settingID = 0", withArgumentsIn: [showIntro])
        
    }
   
    
}
