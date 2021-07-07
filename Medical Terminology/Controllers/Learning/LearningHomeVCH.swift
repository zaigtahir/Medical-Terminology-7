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
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let qc = QuestionController()
	private let utilities = Utilities()
   
	// counts, use updateData to update these values as these values are used in multiple areas of the LearningHomeVC
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	var learnedTermsCount = 0
	var totalTermsCount = 0		// based on favoritesOnly mode

	weak var delegate : LearningHomeVCHDelegate?
	
	override init() {
		super.init()
		
		// MARK: - Category notifications
		
		let nameCCCNK = Notification.Name(myKeys.currentCategoryIDsChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryIDsChangedN(notification:)), name: nameCCCNK, object: nil)
		
		// This is sent only if there is this ONE category in currentCategoryIDs, and the name is changed
		let nameCCN = Notification.Name(myKeys.categoryNameChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryNameChangedN(notification:)), name: nameCCN, object: nil)
		
		// MARK: - Term notifications
		let nameTAN = Notification.Name(myKeys.termAddedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termAddedN(notification:)), name: nameTAN, object: nil)
		
		let nameTCN = Notification.Name(myKeys.termChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termChangedN(notification:)), name: nameTCN, object: nil)
		
		
		let nameTDN = Notification.Name(myKeys.termDeletedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termDeletedN(notification:)), name: nameTDN, object: nil)
		
		// MARK: - Favorite status notification
		
		let nameFSC = Notification.Name(myKeys.termFavoriteStatusChanged)
		NotificationCenter.default.addObserver(self, selector: #selector(termFavoriteStatusChangedN (notification:)), name: nameFSC, object: nil)
		
		// update data
		updateData()
		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - Category notification functions

	@objc func currentCategoryIDsChangedN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : [Int]] {
			
			//there will be only one data here, the categoryIDs
			currentCategoryIDs = data["categoryIDs"]!
			updateData()
			delegate?.shouldUpdateDisplay()
			
		}
	}

	@objc func categoryNameChangedN (notification: Notification) {
		// if this is the current category, reload the category and then refresh the display
		delegate?.shouldUpdateDisplay()
	}
	
	// MARK: - Term notification functions
	
	@objc func termAddedN  (notification: Notification) {

		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			let affectedCategoryIDs = tcTB.getTermCategoryIDs(termID: affectedTermID)
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: affectedCategoryIDs) {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func termChangedN  (notification: Notification) {
		// term information change does not affect this VC so nothing to do here
	}
	
	@objc func termDeletedN  (notification: Notification) {
		// self, userInfo: ["assignedCategoryIDs" : assignedCategoryIDs])
		
		if let data = notification.userInfo as? [String: [Int]] {
			//let assignedCategoryIDs = data["assignedCategoryIDs"] as [Int]
			
			let assignedCategoryIDs = data["assignedCategoryIDs"]!
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: assignedCategoryIDs) {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
			
		}
		
		
	}
	
	
	// MARK: - Favorite notification function
	
	@objc func termFavoriteStatusChangedN (notification: Notification) {
	
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			
			let categoryIDs = tcTB.getTermCategoryIDs(termID: affectedTermID)
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: categoryIDs) {
				// a term was affected in the current categories
				updateData()
				delegate?.shouldUpdateDisplay()
			}
			
		}
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
