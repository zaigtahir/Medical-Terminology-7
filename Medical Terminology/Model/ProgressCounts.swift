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
	
	var totalCategoryTerms = 0
	
	func update (categoryID: Int) {
		
		totalCategoryTerms = tcTB.getTermCount(categoryIDs: [categoryID], showFavoritesOnly: false)
		
		let fCount = fc.getFlashcardCount(categoryIDs: [categoryID], showFavoritesOnly: false, learnedStatus: true)
		let lCount = qc.getLearnedTermsCount(categoryIDs: [categoryID], showFavoritesOnly: false)
		let aCount = qc.getCorrectQuestionsCount(categoryIDs: [categoryID], questionType: .both, showFavoritesOnly: false)
		
		fcDone = Float(fCount) / Float(totalCategoryTerms)
		lnDone = Float(lCount) / (Float(totalCategoryTerms) * 2)
		anDone = Float(aCount) / (Float(totalCategoryTerms) * 2)
		
	}
	
	func totalDone () -> Float {
		return (fcDone + lnDone + anDone) / 3
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
