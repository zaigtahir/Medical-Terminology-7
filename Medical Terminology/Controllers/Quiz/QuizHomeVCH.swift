//
//  QuizHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol QuizHomeVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
}


class QuizHomeVCH: NSObject, QuizOptionsUpdated {
    
    private var quizSet: QuizSet!
	var currentCategoryID = 1
	var showFavoritesOnly = false


    var isFavoriteMode  = false
    var numberOfQuestions = 10
    var questionsType : QuestionsType = .random
    var startNewQuiz: Bool = true    //will be used for segue
    
	let tc = TermController()
	let cc = CategoryController2()

	var favoriteTermsCount = 0
	var categoryTermsCount = 20
	
	// after filtering for favorites and question type
	
	var answeredCorrectCount = 20	//
	var totalQuestionsAvailableCount = 200  	// based on showFavoriteOnly mode
	
	weak var delegate: QuizHomeVCHDelegate?
	
	override init() {
		super.init()
		
	}
	
	func updateData () {
		
		// configure isFavorite variable
		var isFavorite : Bool?
			if showFavoritesOnly {
				isFavorite = true
		}
	
		print("updating data, update counts")
		
	}
	
	
	
	
	
	
	/*
	
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
	
	*/
    
    func getMessageText () -> String {
        
		
		return "To code message text"
		
		/*
        let counts = getCounts()
        
        if isFavoriteMode && dIC.getCount(favoriteState: 1) == 0 {
            return "code no favorite message in quizHomeVCH"
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
*/
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
		
		print("code restart over quiz")
      //  dIC.clearAnsweredItems(isFavorite: isFavoriteMode, questionsType: questionsType)
        
        //clear the quiz
         quizSet = nil
        
        
    }

    //MARK: - Delegate functions
    
    func quizOptionsUpdate(numberOfQuestions: Int, questionsTypes: QuestionsType, isFavoriteMode: Bool) {
        //update settings
        self.numberOfQuestions = numberOfQuestions
        self.questionsType = questionsTypes
        self.isFavoriteMode = isFavoriteMode
    }
}
