//
//  QuizSet2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class QuizSet2: TestBase {
	
	/// to save the original termIDs for resetting the learned items when resetting the quiz
	private let termIDs = [Int]()
	private var currentCategoryID = 0
	private let qc = QuestionController2()
	private let tc = TermController()
	
	// to use when making questions
	private struct QuestionInfo {
		let itemID: Int
		let type: Int   //1 term type   //2 definition type
	}

	init (categoryID: Int, numberOfQuestions: Int, favoritesOnly: Bool, questionTypes: TermComponent) {
		// will create a quizset with the numberOfQuesteions if available
		// will only select questions that are not answered or answered incorrectly
		
		// for now just test out term questions
		var questions = [Question2]()
		
		questions.append(qc.makeSampleQuestion())
		questions.append(qc.makeSampleQuestion())
		
		super.init(originalQuestions: questions)
	}
	

	//MARK: Grade related functions
	
	func getLetterGrade() -> String {
		
		let correct = getNumberCorrect()
		let total = getTotalQuestionCount()
		
		let score = Float(correct)/Float(total) * 100
		
		var grade: String
		
		if score >= 90 {
			grade = "A"
			
		} else if score >= 80 {
			grade = "B"
			
		} else if score > 70 {
			grade = "C"
			
		} else if score > 60 {
			grade = "D"
			
		} else {
			grade = "F"
		}
		
		return grade
	}
	
	func getResultsSummary() -> String {
		
		return "You got \(getNumberCorrect()) of \(getTotalQuestionCount()) (\(getPercentCorrect())%) correct"
	}
	
	func getPercentCorrect() -> String {
		let correct = getNumberCorrect()
		let total = getTotalQuestionCount()
		let score = Float(correct)/Float(total) * 100
		
		let percentCorrect =
			String(format: "%.0f", score) //formats to zero decimal place
		return percentCorrect
	}
	
	func selectAnswerToQuestion (questionIndex: Int, answerIndex: Int) {
		
		let question = activeQuestions[questionIndex]
		
		qc.selectAnswer(question: question, answerIndex: answerIndex)
		
		//save answered state
		qc.saveAnsweredStatus(categoryID: currentCategoryID, question: question)
		
		//append question from masterlist to the active list
		moveQuestion()
		
	}
	
	func resetQuizSet () {
		
		print ("code resetQuizSet in QuizSet1")
		
		//dIC.clearAnsweredItems(itemIDs: itemIDs)
		
		//reset()
		
	}
	
	
}
