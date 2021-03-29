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

    func setFavoriteState (button: UIButton, isFavorite: Bool) {
        if isFavorite {
            button.tintColor = myTheme.colorFavorite
        } else {
            button.tintColor = myTheme.colorNotFavorite
        }
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
