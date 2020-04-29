//
//  Utilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/21/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    //sets the enabled and disabled state of my custom buttons
    
    func formatButtonColor (button: UIButton, enabledBackground: UIColor,enabledTint: UIColor, disabledBackground: UIColor, disabledTint: UIColor) {

        if button.isEnabled {
            button.backgroundColor = enabledBackground
            button.tintColor = enabledTint
            button.setTitleColor(enabledTint, for: .normal)
            
        } else {
            button.backgroundColor = disabledBackground
            button.tintColor = disabledTint
            button.setTitleColor(disabledTint, for: .disabled)
        }
        
    }
    
    func setFavoriteState (button: UIButton, isFavorite: Bool) {
        if isFavorite {
            button.tintColor = myTheme.colorFavorite
        } else {
            button.tintColor = myTheme.colorNotFavorite
        }
    }
    
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
    
    func getPercentage (number: Int, numberTotal: Int) -> String {
        
        let percent = Float(number)/Float(numberTotal) * 100
        if percent < 1 || (percent > 99 && percent < 100) {
            return String(format: "%.1f", percent) //formats to zero decimal place
        } else   {
            return String(format: "%.0f", percent) //formats to one decimal place
        }
    }
    
    func makeSampleDBEntries () {
        
        let dIC = DItemController()
        
        dIC.saveAnsweredTerm(itemID: 2, answerState: 2)
        dIC.saveAnsweredTerm(itemID: 3, answerState: 2)
        dIC.saveAnsweredTerm(itemID: 4, answerState: 2)
        
        dIC.saveFavorite(itemID: 4, isFavorite: true)
        dIC.saveFavorite(itemID: 5, isFavorite: true)
        dIC.saveFavorite(itemID: 11, isFavorite: true)
        
        dIC.saveAnsweredDefinition(itemID: 3, answerState: 2)
        dIC.saveAnsweredDefinition(itemID: 4, answerState: 2)
        
        dIC.saveLearnedTerm(itemID: 10, learnedState: true)
        dIC.saveLearnedTerm(itemID: 11, learnedState: true)
        dIC.saveLearnedTerm(itemID: 12, learnedState: true)
        dIC.saveLearnedTerm(itemID: 13, learnedState: true)
        dIC.saveLearnedTerm(itemID: 14, learnedState: true)
        dIC.saveLearnedTerm(itemID: 15, learnedState: true)
        
        dIC.saveLearnedDefinition(itemID: 11, learnedState: true)
        dIC.saveLearnedDefinition(itemID: 12, learnedState: true)
        dIC.saveLearnedDefinition(itemID: 13, learnedState: true)
        dIC.saveLearnedDefinition(itemID: 14, learnedState: false)
    }
    
   
    
}
