//
//  QuizHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class QuizHomeVCH {
    
    private var quizSet: QuizSet!   //initialize for first time when user presses the "Start New Set"
    private let dIC = DItemController()
    
    var isFavoriteMode  = false
    var numberOfQuestions = 10
    var questionsType : QuestionsType = .random
    var startNewQuiz: Bool = true    //will be used for segue
    
    init () {
    }
    
    /**
     Will return counts based on favorite mode and questions typea
     */
    func getCounts () -> (answeredCorrectly: Int, availableToAnswer: Int, totalQuestions: Int) {
        
        let totalItems = dIC.getCount(favoriteState: -1)
        let totalFavoriteItems = dIC.getCount(favoriteState: 1)
        
        var favoriteState = -1
        if isFavoriteMode {
            favoriteState = 1
        }
        
        var answeredCorrectlyLocal = -1
        var availableToAnswerLocal = -1
        var totalQuestionsLocal = -1
        
        switch questionsType {
            
        case .random:
            answeredCorrectlyLocal = dIC.getTermsAnsweredCorrectlyCount(favoriteState: favoriteState) + dIC.getDefinitionsAnsweredCorrectly(favoriteState: favoriteState)
            
            if isFavoriteMode {
                totalQuestionsLocal = totalFavoriteItems * 2
            } else {
                totalQuestionsLocal = totalItems *  2
            }
            
        case .term:
            answeredCorrectlyLocal = dIC.getTermsAnsweredCorrectlyCount(favoriteState: favoriteState)
            if isFavoriteMode {
                totalQuestionsLocal = totalFavoriteItems
            } else {
                totalQuestionsLocal = totalItems
            }
            
        default:
            answeredCorrectlyLocal = dIC.getDefinitionsAnsweredCorrectly(favoriteState: favoriteState)
            if isFavoriteMode {
                totalQuestionsLocal = totalFavoriteItems
            } else {
                totalQuestionsLocal = totalItems
            }
        }
        
        availableToAnswerLocal = totalQuestionsLocal - answeredCorrectlyLocal
        
        return (answeredCorrectlyLocal, availableToAnswerLocal, totalQuestionsLocal)
        
    }
    
    func getMessageText () -> String {
        
        let counts = getCounts()
        
        if isFavoriteMode && dIC.getCount(favoriteState: 1) == 0 {
            return "You don't have any favorites selected to show here. You can select some on the Flascards or the List tabs to see them here."
        }
        
        var favoriteText = ""
        if isFavoriteMode {
            favoriteText = " Favorite"
        }
        
        var questionTypeText = ""
        
        switch questionsType {
            
        case .random:
            questionTypeText = ""
            
        case .term:
            
            questionTypeText = " Terms-Only"
            
        default:
            questionTypeText = " Definitions-Only"
        }
        
        var messageLabel: String
        
        if counts.availableToAnswer == 0 {
            messageLabel = "You have correctly answered\nall \(counts.totalQuestions)\(favoriteText)\(questionTypeText) questions"
        } else {
            messageLabel = "You have correctly answered\n\(counts.answeredCorrectly) of \(counts.totalQuestions)\(favoriteText)\(questionTypeText) questions"
        }
        
        return messageLabel
    }
    
    func isQuizSetAvailable () -> Bool {
        // test to see if the quiz exists
        // can use to set the enabled state of the See current set button
        if let _ = quizSet {
            return true
        } else {
            return false
        }
    }
    
    func getQuizSet () -> QuizSet {
        return quizSet
    }
    
    func getNewQuizSet () -> QuizSet {
        
        //create a quiz based on the variables that can be changed through options
        var favoriteState = -1
        if isFavoriteMode {
            favoriteState = 1
        }
    
        quizSet = QuizSet(numberOfQuestions: numberOfQuestions, favoriteState: favoriteState, questionTypes: questionsType)
        
        return quizSet
    }
    
    func restartOver () {
        //clear the answered items specific to the filter items
        dIC.clearAnsweredItems(isFavorite: isFavoriteMode, questionsType: questionsType)
        
        //clear the quiz
         quizSet = nil
        
        
    }

}
