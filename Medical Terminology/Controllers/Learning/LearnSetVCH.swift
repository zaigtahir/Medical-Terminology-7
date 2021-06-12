//
//  LearnVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/12/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol LearningSetVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
	func shouldUpdateData()
	func shouldRestartSet()
}

class LearningSetVCH: NSObject, UICollectionViewDataSource, ScrollControllerDelegate, LearnCVCellDelegate, LearnDoneCVCellDelegate {

	// configure with configure function in when setting up segue
    var learningSet: LearningSet!
	
	weak var delegate: LearningSetVCHDelegate?
    
    // Will return true if the collection view is displaying the last card (summary)
    func isAtSummary (indexPath: IndexPath) -> Bool {
        
        let row = indexPath.row
        
        if (row == learningSet.activeQuestions.count - 1) && (learningSet.masterList.count == 0) {
            return true
        } else {
            return false
        }
    }
 
	//MARK: - collection view datasource and delegate methods
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let numItems =  learningSet.getActiveQuestionsCount()
		return numItems
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		//need to figure out a better way to know when im at the summary card
		
		if isAtSummary(indexPath: indexPath) {
			//need to show the summary cell
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnDoneCell", for: indexPath) as! LearnDoneCVCell
			cell.delegate = self
			return cell
		} else {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnCell", for: indexPath) as! LearnCVCell
			cell.delegate = self
			
			let question = learningSet.getQuestion(index: indexPath.row)
			let quizStatus = learningSet.getQuizStatus()
			
			cell.configure(question: question, questionIndex: indexPath.row, totalQuestions: learningSet.getTotalQuestionCount(), quizStatus: quizStatus)
			
			return cell
		}
	}
	
	func questionIndexChanged(questionIndex: Int, lastIndex: Int) {
		//delegate function from the collection view delegate, this is when the collection view is moved
		delegate?.shouldUpdateDisplay()
		
	}
	
	//MARK:- delegate function for LearnCVCell delegate, this is when the user selects an answer
	func selectedAnswer(questionIndex: Int, answerIndex: Int) {
		//if this is answered already, don't do anything
		let question  = learningSet.getQuestion(index: questionIndex)
		if question.isAnswered() {
			//don't do anything
			return
		}
		
		learningSet.selectAnswerToQuestion(questionIndex: questionIndex, answerIndex: answerIndex)
		
		delegate?.shouldUpdateData()
		delegate?.shouldUpdateDisplay()
		
	}
	
	func showAgain(questionIndex: Int) {
		print("user pressed the show again button")
		
		learningSet.activeQuestions[questionIndex].showAgain = true
		
		learningSet.requeueQuestion(questionIndex: questionIndex)
		
		delegate?.shouldUpdateData()
		delegate?.shouldUpdateDisplay()
		
	}
	
	func showAnswer(questionIndex: Int, showAnswer: Bool) {
		// just update the question information here to be used
		// when the user changes the cards
		// in the cell, the action will just toggle the
		// view locally
		
		learningSet.activeQuestions[questionIndex].showAnswer = showAnswer
	}
	
	//MARK: - delegate function for LearnDoneCVDellDelegate
	func retartButtonPressed() {
		delegate?.shouldRestartSet()
	}
	
	//MARK: - scroll controller delegate functions
	func CVCellChanged(cellIndex: Int) {
		delegate?.shouldUpdateDisplay()
	}
	
	func CVCellDragging(cellIndex: Int) {
		//won't do anything here, but the function is here to satisfy the protocol
	}

}


