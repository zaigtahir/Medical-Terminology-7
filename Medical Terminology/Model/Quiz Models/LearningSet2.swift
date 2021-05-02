//
//  LearningSet2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

//  Class to extend QuizBase to make a LearningSet

class LearningSet2: QuizBase {
	
	//private let dIC = DItemController()
	
	//private let itemIDs: [Int]  //to save the original itemIDs for resetting the learned items when resetting the quiz
	
	
	private let tc = TermController()
	
	private let termIDs : [Int]	 //to save the original termIDs for resetting the learned items when resetting the quiz
	
	private let qc = QuestionController2()
	
	init (categoryID: Int, numberOfTerms: Int, favoritesOnly: Bool) {
		
		// will create a learning set with the numberOfTerms if available
		// It will select terms that are not learned yet (BOTH learnedTerm AND learnedDescription DO NOT EQUAL 1)
		
		termIDs = tc.getTermIDs(categoryID: categoryID, favoritesOnly: favoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: false, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none, orderByName: false, randomOrder: true, limitTo: numberOfTerms)

		
		//need to clear all learnedTerm and learnedQuestion from the items in the db
		dIC.clearLearnedItems(itemIDs: itemIDs)
		
		var questions = [Question]()
		
		for itemID in itemIDs {
			questions.append(questionController.makeTermQuestion(itemID: itemID, randomizeAnswers: true))
			questions.append(questionController.makeDefinitionQuestion(itemID: itemID, randomizeAnswers: true))
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
				dIC.saveLearnedTerm(itemID: question.itemID, learnedState: false)
			}
		} else {
			//it is definition type question
			if question.learnedDefinitionForItem == true {
				//set to false in db
				dIC.saveLearnedDefinition(itemID: question.itemID, learnedState: false)
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
		
		questionController.selectAnswer(question: question, answerIndex: answerIndex)
		
		if question.isCorrect() {
			
			if question.questionType == .term {
				
				question.learnedTermForItem = true
				
			} else {
				
				question.learnedDefinitionForItem = true
			}
		}
		
		//save learned state
		questionController.saveLearnedStatus(question: question)
		
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
		dIC.clearLearnedItems(itemIDs: itemIDs)
		
		//reload the set with the original questions
		reset()
		
	}
	
	
}
