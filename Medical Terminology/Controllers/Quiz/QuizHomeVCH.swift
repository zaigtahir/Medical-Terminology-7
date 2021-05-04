//
//  QuizHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol QuizHomeVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
}


class QuizHomeVCH: NSObject, QuizOptionsUpdated {
    
    private var quizSet: QuizSet!
	
	var currentCategoryID = 1
	var favoritesOnly = false
    var numberOfQuestions = 10
    var questionsType : TermComponent = .both
	
    var startNewQuiz: Bool = true    //will be used for segue
    
	let tc = TermController()
	let cc = CategoryController2()
	let qc = QuestionController2()

	// counts of items
	var favoriteTermsCount = 0
	var categoryTermsCount = 0
	
	// after filtering for favorites and question type
	
	var answeredCorrectCount = 0
	var totalQuestionsCount = 0
	
	weak var delegate: QuizHomeVCHDelegate?
	
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
			
			//there will be only one data here, the categoryID
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
		
		// term information does not show on quizHome, so nothing do to here
		
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
		
		categoryTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: false)
		
		favoriteTermsCount = tc.getCount2(categoryID: currentCategoryID, favoritesOnly: true)
		
		answeredCorrectCount = qc.getCorrectQuestionsCount(categoryID: currentCategoryID, questionType: questionsType, favoriteOnly: favoritesOnly)
		
		totalQuestionsCount = qc.getTotalQuestionsCount(categoryID: currentCategoryID, questionType: questionsType, favoriteOnly: favoritesOnly)
		
	}
    
    func isQuizSetAvailable () -> Bool {
        // test to see if the quiz exists
        // can use to set the enabled state of the See current set button
        if let _ = quizSet {
            return true
        } else {
            return false
        }
    }
    
    func getQuizSet () -> QuizSet {
        return quizSet
    }
    
    func getNewQuizSet () -> QuizSet {
        
        //create a quiz based on the variables that can be changed through options
       
		quizSet = QuizSet(categoryID: currentCategoryID, numberOfQuestions: numberOfQuestions, favoritesOnly: favoritesOnly, questionsTypes: questionsType)
        
        return quizSet
    }
    
    func restartOver () {
        //clear the answered items specific to the filter items
		
		print("code restart over quiz")
      //  dIC.clearAnsweredItems(isFavorite: isFavoriteMode, questionsType: questionsType)
        
        //clear the quiz
         quizSet = nil
        
        
    }

    //MARK: - Delegate functions
    
    func quizOptionsUpdate(numberOfQuestions: Int, questionsTypes: TermComponent, isFavoriteMode: Bool) {
        //update settings
        self.numberOfQuestions = numberOfQuestions
        self.questionsType = questionsTypes
    }
}
