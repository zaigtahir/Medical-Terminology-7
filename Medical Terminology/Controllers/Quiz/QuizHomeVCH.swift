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
	var favoritesOnly = false
    var numberOfQuestions = 10
    var questionsType : TermComponent = .both
	
    var startNewQuiz: Bool = true    //will be used for segue
    
	let tc = TermController()
	let cc = CategoryController2()
	let qc = QuestionController2()

	// counts of items
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	
	// after filtering for favorites and question type
	
	var answeredCorrectCount = 0
	var totalQuestionsCount = 0
	
	weak var delegate: QuizHomeVCHDelegate?
	
	override init() {
		super.init()
		
	}
	
	func updateData () {
		
		categoryTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: false)
		
		favoriteTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: true)
		
		answeredCorrectCount = qc.getCorrectQuestionsCount(categoryID: currentCategoryID, questionType: questionsType, favoriteOnly: favoritesOnly)
		
		totalQuestionsCount = qc.getTotalQuestionsCount(categoryID: currentCategoryID, questionType: questionsType, favoriteOnly: favoritesOnly)
		
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
       
		quizSet = QuizSet(categoryID: currentCategoryID, numberOfQuestions: numberOfQuestions, favoritesOnly: favoritesOnly, questionsTypes: questionsType)
        
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
    
    func quizOptionsUpdate(numberOfQuestions: Int, questionsTypes: TermComponent, isFavoriteMode: Bool) {
        //update settings
        self.numberOfQuestions = numberOfQuestions
        self.questionsType = questionsTypes
    }
}
