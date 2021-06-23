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
	
	var currentCategoryID = 1
	var favoritesOnly = false
    var numberOfQuestions = 10
    var questionsType : TermComponent = .both
	
    var startNewTest: Bool = true    //will be used for segue
    
	let tc = TermController()
	let cc = CategoryController()
	let qc = QuestionController()

	// counts of items
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	
	// after filtering for favorites and question type
	
	var answeredCorrectCount = 0
	var totalQuestionsCount = 0
	
	weak var delegate: TestHomeVCHDelegate?
	
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
		
		let nameDCK = Notification.Name(myKeys.categoryDeletedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryDeletedN (notification:)), name: nameDCK, object: nil)
		
		let nameCCN = Notification.Name(myKeys.categoryNameChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryNameChangedN(notification:)), name: nameCCN, object: nil)
		
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
			
			// clear the test set
			if testSet != nil {
				testSet = nil
			}
			
			
			// there will be only one data here, the categoryID
			currentCategoryID = data["categoryID"]!
			updateData()
			delegate?.shouldUpdateDisplay()
		}
	}
	
	@objc func setFavoriteStatusN (notification: Notification) {
		
		// an item changed it's favorite status, will need to update the counts
		updateData()
		delegate?.shouldUpdateDisplay()
	}
	
	@objc func termInformationChangedN (notification: Notification) {
		
		// term information does not show on testHome, so nothing do to here
		
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
		
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func categoryDeletedN (notification: Notification){
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
	
	@objc func categoryNameChangedN (notification: Notification) {
		// if this is the current category, reload the category and then refresh the display
		
		if let data = notification.userInfo as? [String : Int] {
			let changedCategoryID = data["categoryID"]
			if changedCategoryID == currentCategoryID {
				delegate?.shouldUpdateDisplay()
			}
		}
		
	}
	
	func updateData () {
		
		categoryTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: false)
		
		favoriteTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: true)
		
		answeredCorrectCount = qc.getCorrectQuestionsCount(categoryID: currentCategoryID, questionType: questionsType, favoriteOnly: favoritesOnly)
		
		totalQuestionsCount = qc.getTotalQuestionsCount(categoryID: currentCategoryID, questionType: questionsType, favoriteOnly: favoritesOnly)
		
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
       
		testSet = TestSet(categoryID: currentCategoryID, numberOfQuestions: numberOfQuestions, favoritesOnly: favoritesOnly, questionsTypes: questionsType)
        
        return testSet
    }
    
    func restartOver () {
		
		qc.resetAnswers(categoryID: currentCategoryID, questionType: questionsType)
	
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
