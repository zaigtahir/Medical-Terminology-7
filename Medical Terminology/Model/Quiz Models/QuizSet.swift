//
//  QuizSet2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class QuizSet: TestBase {
	
	/// to save the original termIDs for resetting the learned items when resetting the quiz
	private let termIDs = [Int]()
	private var currentCategoryID = 0
	private let qc = QuestionController2()
	private let tc = TermController()
	
	init (categoryID: Int, numberOfQuestions: Int, favoritesOnly: Bool, questionsTypes: TermComponent) {
		// will create a quizset with the numberOfQuesteions if available
		// will only select questions that are not answered or answered incorrectly
		
		// for now just test out term questions
		var questions = [Question2]()
		
		switch questionsTypes {
		case .term:
			questions = qc.getAvilableTermQuestions(categoryID: currentCategoryID, numberOfQuestions: 2, favoriteOnly: favoritesOnly)
			
		case .definition:
			questions = qc.getAvailableDefinitionQuestions(categoryID: currentCategoryID, numberOfQuestions: 2, favoriteOnly: favoritesOnly)
			
		case .both:
			questions = qc.getAvailableQuestions(categoryID: currentCategoryID, numberOfQuestions: numberOfQuestions, favoritesOnly: favoritesOnly)
		}
		
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
