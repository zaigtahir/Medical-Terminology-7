//
//  AudioFilesController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/29/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation

class AudioFileController {
    
    private func getAudioFileNamesFromDB () -> [String] {
        //will return an array of audio file names from the database
        
        //return an array of audio file names
        //if nothing found return an empty array
        
        //null strings in database will become an empty string in the string variables here
  
        let query = "SELECT audioFile FROM dictionary WHERE itemID >= 0"
        
        var fileNames = [String]()
        
        if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
            
            while resultSet.next() {
                
                let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
                fileNames.append(audioFile)
                
            }
            
        }
        
        return fileNames
        
    }
    
    func checkAudioFiles () {
        //will check to see if each audiofile listed in the database has a matching file in the resources
        
        let fileNames = getAudioFileNamesFromDB()
        for nameAudioFile in fileNames {
            _ = isResourcePresent(fileName: ("\(nameAudioFile).mp3"))
        }
        
    }
    
    func isResourcePresent (fileName: String) -> Bool {
        //get url to db file in the bundle
        guard Bundle.main.url(forResource: fileName, withExtension: nil) != nil else {
            print("\(fileName) is in db file but NOT IN RESOURCE")
            return false
        }
        return true
    }
    
    
    
    //MARK: Add code to check if an audio resource is present but is not in the database
    //this would be an extra audio file
    
    //testing to see if i can locate the TestFolder bundle file
    func testFolder () {
        //get url to db file in the bundle
        guard Bundle.main.url(forResource: "TestFolder/test", withExtension: "mp3") != nil else {
            print("did not find test.mp3")
            return
        }
        print ("found TestFolder/test.mp3")
    }
    
    
    
}
