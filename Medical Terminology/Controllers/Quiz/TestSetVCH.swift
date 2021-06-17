//
//  TestSetVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol TestSetVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
	func shouldUpdateData()
	func shouldRestartTest()
}

class TestSetVCH: NSObject, UICollectionViewDataSource, ScrollControllerDelegate, TestCVCellDelegate, TestDoneCVCellDelegate  {
    
    var testSet: TestSet!      //set this in seque
   
	weak var delegate: TestSetVCHDelegate?
	
    // Will return true if the collection view is displaying the last card (summary)
    func isAtSummary (indexPath: IndexPath) -> Bool {
        
        if indexPath.row == testSet.originalQuestions.count - 1  {
            return true
        } else {
            return false
        }
    }
	
	//MARK: - collection view datasource and delegate methods
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return testSet.getActiveQuestionsCount()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if isAtSummary(indexPath: indexPath)  {
			//need to show the summary cell
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "testDoneCell", for: indexPath) as! TestDoneCVCell
			
			cell.gradeLabel.text = testSet.getLetterGrade()
			cell.resultsLabel.text = testSet.getResultsSummary()
			cell.delegate = self
			return cell
			
		} else {
			
			let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! TestCVCell
			let question = testSet.getQuestion(index: indexPath.row)
			cell.configure(question: question, questionIndex: indexPath.row, totalQuestions: testSet.getTotalQuestionCount())
			cell.delegate = self
			return cell
		}
	}
	
	func questionIndexChanged(questionIndex: Int, lastIndex: Int) {
		//delegate function from the collection view delegate, this is when the collection view is moved
		delegate?.shouldUpdateDisplay()
	}
	
	// END collection view delegate functions
	
	//MARK: - scroll controller delegate functions
	func CVCellChanged(cellIndex: Int) {
		delegate?.shouldUpdateDisplay()
	}
	
	func CVCellDragging(cellIndex: Int) {
		//won't do anything here, but the function is here to satisfy the protocol
	}

	//MARK: - delegate functions TestCVCellDelegate,
	func selectedAnswer(questionIndex: Int, answerIndex: Int) {
				
		//if this is answered already, don't do anything
		let question  = testSet.getQuestion(index: questionIndex)
		if question.isAnswered() {
			//don't do anything
			return
		}
		
		testSet.selectAnswerToQuestion(questionIndex: questionIndex, answerIndex: answerIndex)
		testSet.addFeedbackRemarks(question: question)
		
		delegate?.shouldUpdateData()
		delegate?.shouldUpdateDisplay()

	}
	
	func showAnswer(questionIndex: Int, showAnswer: Bool) {
		testSet.activeQuestions[questionIndex].showAnswer = showAnswer
	}
	
	//end delegate functions
	
	//MARK: - delegate functions TestDoneCVCellDelegate
	
	func retartButtonPressed() {
		delegate?.shouldRestartTest()
	}
	
	
}
