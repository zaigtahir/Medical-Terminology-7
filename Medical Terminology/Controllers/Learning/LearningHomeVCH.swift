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
	let tc = TermController()
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
		
		/*
		Notification keys this controller will need to respond to
		
		currentCategoryChangedKey
		setFavoriteStatusKey
		assignCategoryKey
		unassignCategoryKey
		deleteCategoryKey
		changeCategoryNameKey
		*/
		
		let nameCCCN = Notification.Name(myKeys.currentCategoryChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryChangedN(notification:)), name: nameCCCN, object: nil)
		
		let nameSFK = Notification.Name(myKeys.setFavoriteStatusKey)
		NotificationCenter.default.addObserver(self, selector: #selector(setFavoriteStatusN (notification:)), name: nameSFK, object: nil)
		
		let nameACK = Notification.Name(myKeys.assignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(assignCategoryN(notification:)), name: nameACK, object: nil)
		
		let nameUCK = Notification.Name(myKeys.unassignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(unassignCategoryN(notification:)), name: nameUCK, object: nil)
		
		let nameDCK = Notification.Name(myKeys.deleteCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteCategoryN (notification:)), name: nameDCK, object: nil)
		
		let nameCCN = Notification.Name(myKeys.changeCategoryNameKey)
		NotificationCenter.default.addObserver(self, selector: #selector(changeCategoryNameN(notification:)), name: nameCCN, object: nil)
		
		let nameTIC = Notification.Name(myKeys.termInformationChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termInformationChangedN(notification:)), name: nameTIC, object: nil)
		
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
	
	// MARK: ADD notification for term information changed (different than favorite status changed)
	
	@objc func termInformationChangedN (notification: Notification) {
		// nothing to do for learning home
	}
	
	@objc func assignCategoryN (notification : Notification) {
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		
		print("fcVCH got unassignCategoryN")
		
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func deleteCategoryN (notification: Notification){
		// if the current category is deleted, then change the current category to 1 (All Terms) and reload the data
		if let data = notification.userInfo as? [String: Int] {
			
			let deletedCategoryID = data["categoryID"]
			if deletedCategoryID == currentCategoryID {
				currentCategoryID = myConstants.dbCategoryAllTermsID
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func changeCategoryNameN (notification: Notification) {
		// if this is the current category, reload the category and then refresh the display
		
		if let data = notification.userInfo as? [String : Int] {
			let changedCategoryID = data["categoryID"]
			if changedCategoryID == currentCategoryID {
				delegate?.shouldUpdateDisplay()
			}
		}
		
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
