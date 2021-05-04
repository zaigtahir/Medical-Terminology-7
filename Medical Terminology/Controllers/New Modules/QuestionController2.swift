//
//  QuestionController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class QuestionController2 {
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	
	let tc = TermController()
	
	// MARK: shorter table names to make things easier
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	/// question is term, answers are definitions which do not include the definition in the term
	func makeTermQuestion (termID: Int, randomizeAnswers: Bool) -> Question2 {
		
		let term = tc.getTerm(termID: termID)
		let question = Question2 ()
		
		question.questionType = .term
		question.termID = term.termID
		question.questionText = term.name
		question.answers[3].answerText = term.definition
		question.answers[3].isCorrect = true
		
		//now add the answers
		let otherAnswers = get3DefinitionAnswers(notIncluding: term.definition)
		
		for i in 0...2 {
			question.answers[i].answerText = otherAnswers[i]
			question.answers[i].isCorrect = false
		}
		
		//randomize the answers
		if randomizeAnswers {
			question.answers.shuffle()
		}
		return question
	}
	
	/// question is definition, anwers are terms which do not include the term name
	func makeDefinitionQuestion (termID: Int, randomizeAnswers: Bool) -> Question2 {
		
		let term = tc.getTerm(termID: termID)
		
		let question = Question2 ()
		question.questionType = .definition
		question.termID = term.termID
		question.questionText = term.definition
		
		question.answers[3].answerText = term.name
		question.answers[3].isCorrect = true
		
		//now add the answers
		let otherAnswers = get3TermAnswers(notIncluding: term.name)
		
		for i in 0...2 {
			question.answers[i].answerText = otherAnswers[i]
			question.answers[i].isCorrect = false
		}
		//randomize the answers
		if randomizeAnswers {
			question.answers.shuffle()
		}
		return question
	}
	
	func makeRandomTypeQuestion (termID: Int, randomizeAnswers: Bool) -> Question2 {
		
		let r = Int.random(in: 0...1)
		
		if (r == 0) {
			return makeDefinitionQuestion(termID: termID, randomizeAnswers: randomizeAnswers)
		} else {
			return makeTermQuestion (termID: termID, randomizeAnswers: randomizeAnswers)
		}
		
	}
	
	func makeSampleQuestion () -> Question2 {
		let question = Question2()
		question.termID = 0
		
		question.questionText = "This is sample question text"
		let a0 = Answer(answerText: "Answer index 0", isCorrect: false)
		let a1 = Answer(answerText: "Answer index 1", isCorrect: false)
		let a2 = Answer(answerText: "Answer index 2", isCorrect: false)
		let a3 = Answer(answerText: "Answer index 3", isCorrect: true)
		
		question.answers.append(a0)
		question.answers.append(a1)
		question.answers.append(a2)
		question.answers.append(a3)
		
		return question
	}
	
	/// return three random terms from the complete list not to include term stated
	private func get3TermAnswers(notIncluding: String) -> [String] {
		
		var termNames = [String]()
		
		let query = "SELECT DISTINCT name, REPLACE (name, '-' , '') AS noHyphenInName FROM \(terms) WHERE name != '\(notIncluding)' AND noHyphenInName != '\(notIncluding)' ORDER BY RANDOM () LIMIT 3"
		
		print("question controller get3TermAnswers query: \(query)")
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			
			while resultSet.next() {
				let name = resultSet.string(forColumn: "name") ?? ""
				termNames.append(name)
			}
		}
		
		return termNames
	}
	
	/// return 3 random definitions not to include the definition stated
	private func get3DefinitionAnswers(notIncluding: String) -> [String]{
		
		
		var definitions = [String]()
		
		let query = "SELECT DISTINCT definition FROM \(terms) WHERE definition != '\(notIncluding)' ORDER BY RANDOM () LIMIT 3"
		
		print("question controller get3DefinitionAnswers query: \(query)")
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			
			while resultSet.next() {
				let definition = resultSet.string(forColumn: "definition") ?? ""
				definitions.append(definition)
			}
		}
		
		
		return definitions
	}
	
	func selectAnswer (question: Question2, answerIndex: Int) {
		question.selectAnswerIndex(answerIndex: answerIndex)
	}
	
	func saveLearnedStatus (categoryID: Int, question: Question2) {
		
		if question.questionType == .term
		
		{
			tc.setLearnedTerm (categoryID: categoryID, termID: question.termID, learned: question.learnedTermForItem)
			
		} else {
			
			tc.setLearnedDefinition(categoryID: categoryID, termID: question.termID, learned: question.learnedDefinitionForItem)
			
		}
		
	}
	
	func saveAnsweredStatus (categoryID: Int, question: Question2) {
		
		switch question.questionType {
		case .term:
			
			var answeredTermState = AnsweredState.unanswered
			
			if question.isAnswered() {
				if question.isCorrect() {
					answeredTermState = .correct
				} else {
					answeredTermState = .incorrect
				}
			}
			
			tc.setAnsweredTerm(categoryID: categoryID, termID: question.termID, answeredState: answeredTermState)
			
		case .definition:
			
			var answeredDefinitionState = AnsweredState.unanswered
			
			if question.isAnswered() {
				if question.isCorrect() {
					answeredDefinitionState = .correct
				} else {
					answeredDefinitionState = .incorrect
				}
			}
			
			tc.setAnsweredDefinition(categoryID: categoryID, termID: question.termID, answeredState: answeredDefinitionState)
			
		case .both:
			// won't ever be called
			print("fatal error don't expect questiontype = both in question controller saveAsnsweredStatus")
			return
		}
	}
	
	func isLearned (categoryID: Int, question: Question2) -> Bool {
		//will return true if both learned term and learned defintion are true
		
		let termIsLearned = tc.termIsLearned(categoryID: categoryID, termID: question.termID)
		let definitionIsLearned = tc.definitionIsLearned(categoryID: categoryID, termID: question.termID)
		
		return termIsLearned && definitionIsLearned
		
	}
	
	
	
	// MARK: - quiz questions
	
	/// return array of ids where answeredTerm = unanswered OR incorrect
	func getAvilableTermQuestions (categoryID: Int, numberOfTerms: Int, favoriteOnly: Bool) -> [Question2] {
		
		var questions = [Question2]()
		
		var favoriteString = ""
		if favoriteOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		
		let query = """
			SELECT termID FROM \(assignedCategories)
			WHERE termAnswered != \(AnsweredState.correct.rawValue) \(favoriteString)
			ORDER BY RANDOM ()
			LIMIT \(numberOfTerms)
			"""
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let termID = Int(resultSet.int(forColumnIndex: 0))
				let q = makeTermQuestion(termID: termID, randomizeAnswers: true)
				questions.append(q)
			}
		}
		
		return questions
		
	}
	
	/// return array of ids where answeredDefinition = unanswered OR incorrect
	func getAvailableDefinitionQuestions (categoryID: Int, numberOfTerms: Int, favoriteOnly: Bool) -> [Question2]  {
		
		var questions = [Question2]()
		
		var favoriteString = ""
		if favoriteOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		
		let query = """
			SELECT termID FROM \(assignedCategories)
			WHERE definitionAnswered != \(AnsweredState.correct.rawValue) \(favoriteString)
			ORDER BY RANDOM ()
			LIMIT \(numberOfTerms)
			"""
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let termID = Int(resultSet.int(forColumnIndex: 0))
				let q = makeDefinitionQuestion(termID: termID, randomizeAnswers: true)
				questions.append(q)
			}
		}
		
		return questions
	}
	
	/// return array of ids where (answeredTerm = unanswered OR incorrect) OR (answeredDefinition = unanswered OR incorrect)
	private func getAvailableQuestions (categoryID: Int, numberOfTerms: Int, favoriteOnly: Bool)  {
		
		var favoriteString = ""
		if favoriteOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		let query = """
		SELECT * FROM
		(
		SELECT itemID, 1 as type from dictionary  WHERE answeredTerm != \(AnsweredState.correct.rawValue) \(favoriteString) ORDER BY RANDOM ()
		UNION
		SELECT itemID, 2 as type from dictionary  WHERE answeredDefinition != \(AnsweredState.correct.rawValue) \(favoriteString) ORDER BY RANDOM ()
		)
		ORDER BY RANDOM()
		LIMIT \(numberOfTerms)
		"""
		
		
		
	}
	
}
