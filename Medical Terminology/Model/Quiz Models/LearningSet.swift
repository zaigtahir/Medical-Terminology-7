//
//  LearningSet.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

//  Class to extend TestBase to make a LearningSet

// MARK: change to use TestBase

class LearningSet: QiuzTestBase {
	
	/// to save the original termIDs for resetting the learned items when resetting the test
	private let termIDs : [Int]
	private var currentCategoryIDs = [1]
	private let qc = QuestionController()
	private let tc = TermController()
	
	init (categoryIDs: [Int], numberOfTerms: Int, showFavoritesOnly: Bool) {
		
		// will create a learning set with the numberOfTerms if available
		
		currentCategoryIDs = categoryIDs
		
		termIDs = qc.getTermIDsAvailableToLearn(categoryIDs: categoryIDs, numberOfTerms: numberOfTerms, showFavoritesOnly: showFavoritesOnly)

		// need to clear all learnedTerm and learnedQuestion from the items in the db
				
		qc.resetLearned(termIDs: termIDs)
		
		var questions = [Question]()
		
		for termID in termIDs {
			questions.append(qc.makeTermQuestion(termID: termID, randomizeAnswers: true))
			questions.append(qc.makeDefinitionQuestion(termID: termID, randomizeAnswers: true))
		}
		
		questions.shuffle()
		
		super.init(originalQuestions: questions)
	}

	/**
	 Put a fresh copy of the question into the queue see it again
	 will clear db for the itemID
	 */
	func seeAgain (questionIndex: Int) {
		
		//clear database learned settings
		let question = activeQuestions[questionIndex]
		
		if question.questionType == .term {
			if question.learnedTermForItem == true {
				//set to false in db
				qc.setLearnedTerm(termID: question.termID, learned: false)
				
			}
		} else {
			//it is definition type question
			if question.learnedDefinitionForItem == true {
				//set to false in db
				qc.setLearnedDefinition(termID: question.termID, learned: false)
			}
		}
		
		//now requeue the question using the TestBase
		self.requeueQuestion(questionIndex: questionIndex)
		
	}
	
	//use this function to requeue a correctly answered question
	//add the question to the stack at the back
	//clear the database of learned status
	
	func selectAnswerToQuestion (questionIndex: Int, answerIndex: Int) {
		
		let question = activeQuestions[questionIndex]
		
		qc.selectAnswer(question: question, answerIndex: answerIndex)
		
		if question.isCorrect() {
			
			if question.questionType == .term {
				
				question.learnedTermForItem = true
				
			} else {
				
				question.learnedDefinitionForItem = true
			}
		}
		
		//save learned state
		qc.saveLearnedStatus(question: question)
		
		//add feedback remarks

		addFeedbackRemarks(question: question)
		
		//requeue the question if the answer is wrong
		if !question.isCorrect() {
	
			requeueQuestion(questionIndex: questionIndex)
		}
		
		//append question from masterlist to the active list
		moveQuestion()
		
	}
	
	func resetLearningSet () {
		
		//reset any learned values in the DB
		qc.resetLearned(termIDs: termIDs)
		
		//reload the set with the original questions
		reset()
		
	}
	
	
}
