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
        
        let audioFilesNamesInDB = getAudioFileNamesFromDB()
        
        print("Checking audio files present in DB but missing in Bundle")
        
        //see if each audio file in db has matching file.mp3 in the bundle
        for file in audioFilesNamesInDB {
            
            if Bundle.main.url(forResource: "\(audioFolder)/\(file)", withExtension: "mp3") == nil {
               print("\(audioFolder)/\(file).mp3 is in DB, missing in Bundle")
            }
        }
        
        //see if each mp3 file in the bundle has a matching file in the db
        
        print("Checking audio files present in Bundle but missing in DB")
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!

        do {
            let items = try fm.contentsOfDirectory(atPath: "\(path)/Audio")

            for item in items {
                // see if each item has a match in audioFilesNamesInDB
                // dropping the extension .mp3 so i can compare the the db values
                // have to typecast it to a String as otherwise the fileName will have type string.subseq
                
                let fileName = String(item.dropLast(4))
                if audioFilesNamesInDB.contains(fileName) == false {
                    //the db does not contain this!
                    print("\(fileName).mp3 is present in Bundle, missing in DB")
                }

            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
    
    func isAudioFilePresentInBundle (filename: String, extension: String) ->Bool {
        
        if Bundle.main.url(forResource: "\(audioFolder)/\(filename)", withExtension: "extension") != nil {
           return true
        } else {
            return false
        }
    }

}
