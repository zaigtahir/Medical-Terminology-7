//
//  LearningHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

protocol LearningHomeVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
}

class LearningHomeVCH: NSObject, LearningOptionsUpdated, LearnSetVCDelegate {
	
	private var learningSet: LearningSet!
		
	// default starting
	var currentCategoryIDs = [1]
	
	var showFavoritesOnly = false
	var numberOfQuestions = 10
	
	///used to determine if to create a new set or keep current set when going from learning home to learning set
	var startNewSet = true	//will be used for segue
	let tcTB = TermControllerTB()
	let cc = CategoryController()
	let qc = QuestionController()
   
	// counts, use updateData to update these values as these values are used in multiple areas of the LearningHomeVC
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	var learnedTermsCount = 0
	var totalTermsCount = 0		// based on favoritesOnly mode

	weak var delegate : LearningHomeVCHDelegate?
	
	override init() {
		super.init()
		
		updateData()
		
	}
	
	
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	
	func updateData () {
		
		// learned terms are terms where both the term and the definitions is learned
		
		
		
		categoryTermsCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: false)
		
		favoriteTermsCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: true)
		
		// add to question controller
		
		learnedTermsCount = qc.getLearnedTermsCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: showFavoritesOnly)
		
		if showFavoritesOnly {
			totalTermsCount = favoriteTermsCount
		} else {
			totalTermsCount = categoryTermsCount
		}
			
	}
	
	
	// MARK: - notification functions
	
	func getNewLearningSet () -> LearningSet {
		
		// note number of questions/2 = number of terms which the function needs
		learningSet = LearningSet(categoryIDs: currentCategoryIDs, numberOfTerms: numberOfQuestions/2, showFavoritesOnly: showFavoritesOnly)
		
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
		
		print("LearningHOmeVCH : restartOver () need to code")
		/*
		
		qc.resetLearned(termIDs: termIDs)
		
		// clear the learningSet
		learningSet = nil
		
		updateData()
		
		delegate?.shouldUpdateDisplay()
*/
		
	}
	
	//MARK: - Delegate functions
	func learningOptionsUpdated(numberOfQuestions: Int) {
		self.numberOfQuestions = numberOfQuestions
	}
	
	
	// MARK: - LearnSetVCDelegate
	func doneButtonPressed() {
		updateData()
		delegate?.shouldUpdateDisplay()
	}
}
