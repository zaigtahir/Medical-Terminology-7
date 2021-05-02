//
//  LearningSet2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

//  Class to extend QuizBase to make a LearningSet

class LearningSet2: QuizBase2 {
	
	/// to save the original termIDs for resetting the learned items when resetting the quiz
	private let termIDs : [Int]
	private var currentCategoryID = 0
	private let qc = QuestionController2()
	private let tc = TermController()
	
	init (categoryID: Int, numberOfTerms: Int, favoritesOnly: Bool) {
		
		// will create a learning set with the numberOfTerms if available
		
		currentCategoryID = categoryID
		
		termIDs = tc.getTermIDs(categoryID: categoryID, favoritesOnly: favoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: false, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none, orderByName: false, randomOrder: true, limitTo: numberOfTerms)

		
		// need to clear all learnedTerm and learnedQuestion from the items in the db
		tc.resetLearned(categoryID: categoryID, termIDs: termIDs)
		
		var questions = [Question2]()
		
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
				tc.setLearnedTerm(categoryID: currentCategoryID, termID: question.termID, learned: false)
				
			}
		} else {
			//it is definition type question
			if question.learnedDefinitionForItem == true {
				//set to false in db
				tc.setLearnedDefinition(categoryID: currentCategoryID, termID: question.termID, learned: false)
			}
		}
		
		//now requeue the question using the QuizBase
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
		qc.saveLearnedStatus(categoryID: currentCategoryID, question: question)
		
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
		tc.resetLearned(categoryID: currentCategoryID, termIDs: termIDs)
		
		//reload the set with the original questions
		reset()
		
	}
	
	
}
