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
	
	var currentCategoryID = 1
	var favoritesOnly = false
	var numberOfQuestions = 10
	
	///used to determine if to create a new set or keep current set when going from learning home to learning set
	var startNewSet = true	//will be used for segue
	let tcTB = TermControllerTB()
	let cc = CategoryController()
	let qc = QuestionController()
   
	// counts, use updateData to update these values
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
	
	// MARK: - notification functions
	
	@objc func currentCategoryChangedN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : Int] {
			
			// clear the learning set
			if learningSet != nil {
				learningSet = nil
			}
			
			//there will be only one data here, the categoryID
			currentCategoryID = data["categoryID"]!
			updateData()
			delegate?.shouldUpdateDisplay()
		}
	}
	
	@objc func setFavoriteStatusN (notification: Notification) {
		// a term changed it's favorite status
		updateData()
		delegate?.shouldUpdateDisplay()
	}
	
	func updateData () {
		
		// learned terms are terms where both the term and the definitions is learned
		
		categoryTermsCount = cc.getCountOfTerms(categoryID: currentCategoryID)
		
		favoriteTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: true)
		
		// add to question controller
		
		learnedTermsCount = qc.getLearnedTermsCount(categoryID: currentCategoryID, favoritesOnly: favoritesOnly)
		
		if favoritesOnly {
			totalTermsCount = favoriteTermsCount
		} else {
			totalTermsCount = categoryTermsCount
		}
			
	}
	
	func getNewLearningSet () -> LearningSet {
		
		// note number of questions/2 = number of terms which the function needs
		
		learningSet = LearningSet(categoryID: currentCategoryID, numberOfTerms: numberOfQuestions/2, favoritesOnly: favoritesOnly)
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
		
		qc.resetLearned(categoryID: currentCategoryID)
		
		// clear the learningSet
		learningSet = nil
		
		updateData()
		
		delegate?.shouldUpdateDisplay()
		
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
