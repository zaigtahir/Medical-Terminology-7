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

class TestHomeVCH: NSObject, TestOptionsVCDelegate, TestSetVCDelegate {


    private var testSet: TestSet!
	
	var currentCategoryIDs = [1]
	var showFavoritesOnly = false
    var numberOfQuestions = 10
    var questionsType : TermComponent = .both
	
    var startNewTest: Bool = true    //will be used for segue
    
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let qc = QuestionController()
	private let utilities = Utilities()

	// counts of items
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	var answeredCorrectCount = 0
	var totalQuestionsCount = 0
	
	weak var delegate: TestHomeVCHDelegate?
	
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
		
		let nameTDN = Notification.Name(myKeys.termDeletedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termDeletedN(notification:)), name: nameTDN, object: nil)
		
		let nameTNC = Notification.Name(myKeys.termFieldsChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termFieldsChangedN (notification:)), name: nameTNC, object: nil)
		
		let nameCIC = Notification.Name(myKeys.termCategoryIDsChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termCategoryIDsChangedN (notification:)), name: nameCIC, object: nil)
		
		let nameSFK = Notification.Name(myKeys.termFavoriteStatusChanged)
		NotificationCenter.default.addObserver(self, selector: #selector(termFavoriteStatusChangedN (notification:)), name: nameSFK, object: nil)
		
		// MARK: - reset test questions by categoryVC
		let nameRTQ = Notification.Name(myKeys.resetTestKey)
		NotificationCenter.default.addObserver(self, selector: #selector(resetTestN(notification:)), name: nameRTQ, object: nil)
		
		// update data
		updateData()
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	/*
	Some changes that happen from other parts of the program will affect the terms/questions in the quiz set, so in this case will need to reset the quizset
	
	-- current category changed
	-- term deleted
	-- term category changed
	-- resetTestN
	*/

	// MARK: - Category notification functions

	@objc func currentCategoryIDsChangedN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : [Int]] {
			
			//there will be only one data here, the categoryIDs
			currentCategoryIDs = data["categoryIDs"]!
			
			// reset the test set as it may be affected
			testSet =  nil
			
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

	@objc func termDeletedN  (notification: Notification) {
		// self, userInfo: ["assignedCategoryIDs" : assignedCategoryIDs])
		
		if let data = notification.userInfo as? [String: [Int]] {
			//let assignedCategoryIDs = data["assignedCategoryIDs"] as [Int]
			
			let assignedCategoryIDs = data["assignedCategoryIDs"]!
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: assignedCategoryIDs) {
				
				// reset the test set as it may be affected
				testSet =  nil
				
				updateData()
				delegate?.shouldUpdateDisplay()
			}
			
		}
		
		
	}
	
	@objc func termFieldsChangedN (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			let affectedCategoryIDs = tcTB.getTermCategoryIDs(termID: affectedTermID)
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: affectedCategoryIDs) {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func termCategoryIDsChangedN (notification: Notification) {
		//userInfo: ["termID": [term.termID], "originalCategoryIDs" : [originalTerm.assignedCategories]])
		
		if let data = notification.userInfo as? [String : [Int]] {
			
			let termID = data["termID"]![0]
			let originalCategoryIDs = data["originalCategoryIDs"]!
			let newCategoryIDs = tcTB.getTermCategoryIDs(termID: termID)
			
			// if current categories contain any of these categories, need to refresh data and display
			// this will catch any additions or removals of a term category
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: originalCategoryIDs) || utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: newCategoryIDs) {
				// the current category IDs contain at least one of the category IDs from the originalCategoryIDs or currentCategoryIDs
				
				// reset the test set as it may be affected
				testSet =  nil
				
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func termFavoriteStatusChangedN (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			
			let affectedTermID = data["termID"]!
			
			let aTerm = tcTB.getTerm(termID: affectedTermID)
			
			if !utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: aTerm.assignedCategories) {
				//this term is not in current categories, so do nothing
				return
			} else {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func resetTestN (notification: Notification) {
		// if one of the the current categoryIDs is affected, update the data and display
		
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			
			if currentCategoryIDs.contains(categoryID) {
				
				// reset the learnng set as it may be affected
				testSet =  nil
				
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

	func shouldChangeNumberOfQuestions(numberOfQuestions: Int) {
		self.numberOfQuestions = numberOfQuestions
	}
	
	
	// MARK: TestSetVCDelegate
	func doneButtonPressed() {
		updateData()
		delegate?.shouldUpdateDisplay()
	}
	
}
