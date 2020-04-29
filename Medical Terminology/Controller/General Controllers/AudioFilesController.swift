//
//  AudioFilesController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/29/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation

class AudioFileController {
    
    func getAudioFileNamesFromDB () -> [String] {
        //will return an array of audio file names from the database
        
        //return an array of audio file names
        //if nothing found return an empty array
        
        //null strings in database will become an empty string in the string variables here
        
        //displayTerm will be selected instead of term for the item term if there is something in the displayTerm
        
        let query = "SELECT audioFile FROM dictionary WHERE itemID >= 0"
        
        var fileNames = [String]()
        
        if let resultSet = myFMDB.fmdb.executeQuery(query, withParameterDictionary: nil) {
            
            while resultSet.next() {
                
                let audioFile = resultSet.string(forColumn: "audioFile")  ?? "none found"
                fileNames.append(audioFile)
                
            }
            
        }
        
        return fileNames
        
    }
    
}
