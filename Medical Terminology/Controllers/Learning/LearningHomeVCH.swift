//
//  LearningHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

class LearningHomeVCH: LearningOptionsUpdated  {
    
    private var learningSet: LearningSet!
    let dIC = DItemController()
    
    //default variables until the user changes them with the options settings
    var isFavoriteMode  = false
    var numberOfTerms = 5   //that's the default in settings
    var startNewSet = true  // used to determine if to create a new set or keep current set when going from learning home to learning set
   
    /**
     Will return counts based on favorite mode and questions type
     */
    func getCounts () -> (learnedTerms: Int, availableToLearn: Int, totalTerms: Int) {
        
        // learned terms are terms where both the term and the definitions is learned

        var favoriteState = -1
        
        if isFavoriteMode {
            favoriteState = 1
            
        } else {
            favoriteState = -1
        }
        
        let totalTermsLocal = dIC.getCount(favoriteState: favoriteState) //total terms based on learned state
        
        let learnedTermsLocal = dIC.getCount(favoriteState: favoriteState, learnedState: 1)
        
        let availableToLearnLocal = totalTermsLocal - learnedTermsLocal
        
        return (learnedTerms: learnedTermsLocal, availableToLearn: availableToLearnLocal, totalTerms: totalTermsLocal)
    }
    
    func getMessageText () -> String {
        
        let counts = getCounts()
        
        if isFavoriteMode && dIC.getCount(favoriteState: 1) == 0 {
            return myConstants.noFavoritesAvailableText
        }
        
        var favoriteText = ""
        if isFavoriteMode {
            favoriteText = " Favorite"
        }
        
        var messageLabel: String
        
        if counts.availableToLearn == 0 {
            messageLabel = "You have learned\nall \(counts.totalTerms)\(favoriteText) terms"
        } else {
            messageLabel = "You have learned\n\(counts.learnedTerms) of \(counts.totalTerms)\(favoriteText) terms"
        }
        
        return messageLabel
    }
    
    func getNewLearningSet () -> LearningSet {
        learningSet = LearningSet(numberOfTerms: numberOfTerms, isFavorite: false)
        return learningSet
    }

    func getLearningSet () -> LearningSet {
        return learningSet
    }
    
    func isLearningSetAvailable () -> Bool {
        
        if let _ = learningSet {
            return true
        } else {
            return false
        }
    }

    func restartOver () {
        //clear the learned terms based on favorites filter
        if isFavoriteMode {
            dIC.clearLearnedItems(favoriteState: 1)
        } else {
            dIC.clearLearnedItems(favoriteState: -1)
        }
        
    }
    
    //MARK: - Delegate functions
    
    func learningOptionsUpdated(isFavoriteMode: Bool, numberOfTerms: Int) {
        self.isFavoriteMode = isFavoriteMode
        self.numberOfTerms = numberOfTerms
    }
    
}
