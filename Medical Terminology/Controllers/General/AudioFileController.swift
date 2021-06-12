//
//  AudioFilesController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/29/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioFileController {
    
    var audioPlayer: AVAudioPlayer?
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	let categories = myConstants.dbTableCategories
    
    func getAudioFileNamesFromDB () -> [String] {
        //will return an array of audio file names from the database
        
        //return an array of audio file names
        //if nothing found return an empty array
        
        //null strings in database will become an empty string in the string variables here
        
        let query = "SELECT audioFile FROM \(terms) WHERE termID >= 0"
        
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
        
        print("Checking files present in DB but missing the cooresponding mp3 audiofile in the Audio folder")
        
        //see if each audio file in db has matching file.mp3 in the bundle
        for file in audioFilesNamesInDB {
            
            if Bundle.main.url(forResource: "\(myConstants.audioFolder)/\(file)", withExtension: "mp3") == nil {
                print("\(myConstants.audioFolder)/\(file) is in the DB, but the audiofile is missing in the Audio folder")
            }
        }
        
        //see if each mp3 file in the bundle has a matching file in the db
        
        print("Checking audio files present in the Audio folder but missing in DB")
        
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
                    print("\(fileName).mp3 is present in Audio folder, but missing in Database")
                }
                
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
    
	// MARK: TO REMVE
	
    func isAudioFilePresentInBundle (filename: String, extension: String) ->Bool {
        
        if Bundle.main.url(forResource: "\(myConstants.audioFolder)/\(filename)", withExtension: "mp3") != nil {
            return true
        } else {
            return false
        }
    }

}
