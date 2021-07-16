//
//  ProgressCounts.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/14/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class ProgressCounts {
	
	private let fc = FlashcardController()
	private let qc = QuestionController()
	private let tcTB = TermControllerTB()
	private let utilities = Utilities()
	
	var fcDone : Float = 0.0
	var lnDone : Float = 0.0
	var anDone : Float = 0.0
	
	var fcCount = 0
	var lnCount = 0
	var anCount = 0
	
	var totalCategoryTerms = 0
	
	func update (categoryID: Int) {
		
		totalCategoryTerms = tcTB.getTermCount(categoryIDs: [categoryID], showFavoritesOnly: false)
		
		fcCount = fc.getFlashcardCount(categoryIDs: [categoryID], showFavoritesOnly: false, learnedStatus: true)
		lnCount = qc.getLearnedTermsCount(categoryIDs: [categoryID], showFavoritesOnly: false)
		anCount = qc.getCorrectQuestionsCount(categoryIDs: [categoryID], questionType: .both, showFavoritesOnly: false)
		
		if totalProgressCount() == 0 {
			fcDone = 0
			lnDone = 0
			anDone = 0
			
		} else {
			
			fcDone = Float(fcCount) / Float(totalCategoryTerms)
			lnDone = Float(lnCount) / (Float(totalCategoryTerms) * 2)
			anDone = Float(anCount) / (Float(totalCategoryTerms) * 2)
		}
	}
	
	func totalDone () -> Float {
		return (fcDone + lnDone + anDone) / 3
	}
	
	func totalProgressCount () -> Int {
		return fcCount + lnCount + anCount
	}
	
	func fcDonePercent () -> String {
		return utilities.getPercentage(number: fcDone * 100 )
	}
	
	func lnDonePercent () -> String {
		return utilities.getPercentage(number: lnDone * 100)
	}
	
	func anDonePercent () -> String {
		return utilities.getPercentage(number: anDone * 100 )
	}
	
	func totalDonePercent () -> String {
		return utilities.getPercentage(number: totalDone() * 100)
	}
	
}
