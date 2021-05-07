//
//  Question2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Question {
	//blank questionText
	var questionText: String = ""
	var answers = [Answer]()
	var questionType : TermComponent = .term
	var termID = 0
	var learnedTermForItem = false
	var learnedDefinitionForItem = false
	var showAnswer = false
	var showAgain = false
	var feedbackRemarks = myConstants.feedbackNotAnswered
	
	//initial non selected state. Use to check if this is answered or unanswered
	var selectedAnswerIndex: Int = -1
	
	init () {
		for _ in 0...3 {
			answers.append(Answer(answerText: "default", isCorrect: false))
		}
	}
	
	func isAnswered () -> Bool {
		if (selectedAnswerIndex != -1) {
			return true
		} else {
			return false
		}
	}
	
	func isCorrect () -> Bool {
		//check if the selected answer is correct
		return answers[selectedAnswerIndex].isCorrect
	}
	
	func getCorrectAnswerIndex () -> Int {
		//return the index number of the correct answer
		
		for n in 0...answers.count - 1 {
			if answers[n].isCorrect {
				return n
			}
		}
		
		print ("program error: did not find a correct answer in the list of answers for a question")
		return -1 //if nothing matched, return -1 this should not happen
	}
	
	func getSelectedAnswerIndex () -> Int {
		return selectedAnswerIndex
	}
	
	func selectAnswerIndex (answerIndex: Int) {
		selectedAnswerIndex = answerIndex
	}
	
	func printQuestion () {
		//just prints the question for testing
		print("\nquestionText: \(questionText)")
		
		for i in 0...3 {
			
			var correct: String = ""
			
			if answers[i].isCorrect == true {
				
				correct = "*"
			}
			
			print ("\(i): \(answers[i].answerText) \(correct)")
		}
		
		print("termID: \(termID)")
		print("isAnswered: \(isAnswered())")
		print("questionType: \(questionType)")
		print("learnedTermForItem: \(learnedTermForItem)")
		print("learnedDefinitionForItem: \(learnedDefinitionForItem)")
		print("showAnswer: \(showAnswer)")
		print("showAgain: \(showAgain)")
		print("feebackRemarks: \(feedbackRemarks)")
	}
		
	func getAnswerStatus (answerIndex: Int) -> Int {
		
		// 0 = question is not answered
		// 1 = answer is selected and is correct
		// 2 = answer is selected and is not correct
		// 3 = answer is not selected but is correct
		// 4 = answer is not selected and is not correct
		
		if !isAnswered() {
			return 0
			
		}
		
		if selectedAnswerIndex == answerIndex && selectedAnswerIndex == getCorrectAnswerIndex() {
			return 1
		}
		
		if selectedAnswerIndex == answerIndex && selectedAnswerIndex != getCorrectAnswerIndex() {
			return 2
		}
		
		if selectedAnswerIndex != answerIndex && answerIndex ==  getCorrectAnswerIndex() {
			return 3
		} else {
			// answer is not selected and is not correct
			return 4
		}
		
	}
	
	func getCopy () -> Question {
		
		let question = Question ()
		
		question.questionText = self.questionText
		question.answers = self.answers
		question.selectedAnswerIndex = self.selectedAnswerIndex
		question.termID = self.termID
		question.questionType = self.questionType
		question.learnedTermForItem = self.learnedTermForItem
		question.learnedDefinitionForItem = self.learnedDefinitionForItem
		question.showAnswer = self.showAnswer
		question.showAgain = self.showAgain
		question.feedbackRemarks = self.feedbackRemarks
		
		return question
	}
	/**
	 Will set to unanswered state
	 Will clearn learning fields locally in the question (not in DB)s
	 */
	func resetQuestion () {
		
		selectedAnswerIndex = -1
		learnedTermForItem = false
		learnedDefinitionForItem = false
		learnedTermForItem = false
		learnedDefinitionForItem = false
		showAnswer = false
		showAgain = false
		feedbackRemarks = myConstants.feedbackNotAnswered
	}
}
