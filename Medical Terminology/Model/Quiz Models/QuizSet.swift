//
//  TestSet2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class TestSet: QiuzTestBase {
	
	/// to save the original termIDs for resetting the learned items when resetting the test
	private let termIDs = [Int]()
	private var currentCategoryIDs = [1]
	private let qc = QuestionController()
	private let tc = TermController()
	
	init (categoryIDs: [Int], numberOfQuestions: Int, showFavoritesOnly: Bool, questionsTypes: TermComponent) {
		// will create a testset with the numberOfQuesteions if available
		// will only select questions that are not answered or answered incorrectly
		
		// for now just test out term questions
		var questions = [Question]()
		
		switch questionsTypes {
		
		case .term:
			questions = qc.getAvailableTermQuestions(categoryIDs: categoryIDs, numberOfQuestions: numberOfQuestions, showFavoritesOnly: showFavoritesOnly)
		case .definition:
			questions = qc.getAvailableDefinitionQuestions(categoryIDs: categoryIDs, numberOfQuestions: numberOfQuestions, showFavoritesOnly: showFavoritesOnly)
			
		case .both:
			questions = qc.getAvailableQuestions(categoryIDs: categoryIDs, numberOfQuestions: numberOfQuestions, showFavoritesOnly: showFavoritesOnly)
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
		qc.saveAnsweredStatus(question: question)
		
		//append question from masterlist to the active list
		moveQuestion()
		
	}
	
	func resetTestSet () {
		
		qc.resetAnswers(termIDs: termIDs)
		//reload the set with the original questions
		reset()

	}
	
	
}
