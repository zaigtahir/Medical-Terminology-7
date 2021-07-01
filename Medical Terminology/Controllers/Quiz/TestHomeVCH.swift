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
	let utilities = Utilities()

	// counts of items
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	var answeredCorrectCount = 0
	var totalQuestionsCount = 0
	
	weak var delegate: TestHomeVCHDelegate?
	
	override init() {
		super.init()
		
		// MARK: - Category notifications
		
		let nameCCCNK = Notification.Name(myKeys.currentCategoryIDsChanged)
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
		
		let nameSFK = Notification.Name(myKeys.setFavoriteStatusKey)
		NotificationCenter.default.addObserver(self, selector: #selector(setFavoriteStatusN (notification:)), name: nameSFK, object: nil)
		
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
	
	@objc func setFavoriteStatusN (notification: Notification) {
	
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
