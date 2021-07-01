//
//  TestHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

protocol TestHomeVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
}

// as a note: when the user changes a category, will need to reset the current test

class TestHomeVCH: NSObject, TestOptionsUpdated, TestSetVCDelegate {

    private var testSet: TestSet!
	
	var currentCategoryIDs = [1]
	var showFavoritesOnly = false
    var numberOfQuestions = 10
    var questionsType : TermComponent = .both
	
    var startNewTest: Bool = true    //will be used for segue
    
	let tcTB = TermControllerTB()
	let cc = CategoryController()
	let qc = QuestionController()

	// counts of items
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	var answeredCorrectCount = 0
	var totalQuestionsCount = 0
	
	weak var delegate: TestHomeVCHDelegate?
	
	override init() {
		super.init()
		
		updateData()
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions


	func updateData () {
		

		categoryTermsCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: false)
		
		favoriteTermsCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: true)
		
		answeredCorrectCount = qc.getCorrectQuestionsCount(categoryIDs: currentCategoryIDs, questionType: questionsType, showFavoritesOnly: showFavoritesOnly)
		
		totalQuestionsCount = qc.getTotalQuestionsCount(categoryIDs: currentCategoryIDs, questionType: questionsType, showFavoritesOnly: showFavoritesOnly)
		
	}
    
    func isTestSetAvailable () -> Bool {
        // test to see if the test exists
        // can use to set the enabled state of the See current set button
        if let _ = testSet {
            return true
        } else {
            return false
        }
    }
    
    func getTestSet () -> TestSet {
        return testSet
    }
    
    func getNewTestSet () -> TestSet {
        
        //create a test based on the variables that can be changed through options
		
		testSet = TestSet(categoryIDs: currentCategoryIDs, numberOfQuestions: numberOfQuestions, showFavoritesOnly: showFavoritesOnly, questionsTypes: questionsType)
        
        return testSet
    }
    
    func restartOver () {
	
		qc.resetAnswers(categoryIDs: currentCategoryIDs, questionType: questionsType)
	
        //clear the test
		testSet = nil
        
		updateData()
		
		delegate?.shouldUpdateDisplay()

    }

    //MARK: - Delegate functions
    func testOptionsUpdate(numberOfQuestions: Int, questionsTypes: TermComponent, isFavoriteMode: Bool) {
        //update settings
        self.numberOfQuestions = numberOfQuestions
        self.questionsType = questionsTypes
    }
	
	// MARK: TestSetVCDelegate
	func doneButtonPressed() {
		updateData()
		delegate?.shouldUpdateDisplay()
	}
	
}
