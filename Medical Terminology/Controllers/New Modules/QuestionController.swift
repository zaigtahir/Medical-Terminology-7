//
//  QuestionController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

/**
This class will handle items related to getting and saving items related to questions, test and learning set
*/

class QuestionController {
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	// controllers
	private let tcTB = TermControllerTB()
	private let queries = Queries()
	
	/// question is term, answers are definitions which do not include the definition in the term
	func makeTermQuestion (termID: Int, randomizeAnswers: Bool) -> Question {
		
		let term = tcTB.getTerm(termID: termID)
		let question = Question ()
		
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
	func makeDefinitionQuestion (termID: Int, randomizeAnswers: Bool) -> Question {
		
		let term = tcTB.getTerm(termID: termID)
		
		let question = Question ()
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
	
	func makeRandomTypeQuestion (termID: Int, randomizeAnswers: Bool) -> Question {
		
		let r = Int.random(in: 0...1)
		
		if (r == 0) {
			return makeDefinitionQuestion(termID: termID, randomizeAnswers: randomizeAnswers)
		} else {
			return makeTermQuestion (termID: termID, randomizeAnswers: randomizeAnswers)
		}
		
	}
	
	func makeSampleQuestion () -> Question {
		let question = Question()
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
		
		let query = "SELECT DISTINCT name, REPLACE (name, '-' , '') AS noHyphenInName FROM \(terms) WHERE name != \"\(notIncluding)\" AND noHyphenInName != \"\(notIncluding)\" ORDER BY RANDOM () LIMIT 3"
		
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
		
		let query = "SELECT DISTINCT definition FROM \(terms) WHERE definition != \"\(notIncluding)\" ORDER BY RANDOM () LIMIT 3"
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			
			while resultSet.next() {
				let definition = resultSet.string(forColumn: "definition") ?? ""
				definitions.append(definition)
			}
		}
		
		
		return definitions
	}
	
	func selectAnswer (question: Question, answerIndex: Int) {
		question.selectAnswerIndex(answerIndex: answerIndex)
	}
	
	// MARK: - Learning related functions
	
	func isLearned (termID: Int) -> Bool {
		//will return true if both learned term and learned defintion are true
		
		let query = """
					SELECT COUNT (*) FROM \(terms)
					WHERE
					termID = \(termID)
					AND learnedTerm = 1
					AND learnedDefinition = 1
					"""
		
		if let resultSet =  myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			
			if Int(resultSet.int(forColumnIndex: 0)) == 0 {
				return false
			} else {
				return true
			}
		} else {
			print ("fatal error making result set in isLearned QuestionController, returning false")
			return false
		}
	}
	
	func saveLearnedStatus (question: Question) {
		
		if question.questionType == .term
		
		{
			setLearnedTerm (termID: question.termID, learned: question.learnedTermForItem)
			
		} else {
			
			setLearnedDefinition(termID: question.termID, learned: question.learnedDefinitionForItem)
		}
		
	}
	
	func setLearnedTerm (termID: Int, learned: Bool) {
		
		var lt = 0
		if learned {
			lt = 1
		}
		
		let query = "UPDATE \(terms) SET learnedTerm = \(lt) WHERE (termID = \(termID))"
		
		myDB.executeStatements(query)
		
	}
	
	func setLearnedDefinition  (termID: Int, learned: Bool) {
		
		var ld = 0
		if learned {
			ld = 1
		}
		
		let query = "UPDATE \(terms) SET learnedDefinition = \(ld) WHERE (termID = \(termID))"
		
		myDB.executeStatements(query)
		
	}
	
	/**
	reset all these terms in this category
	*/
	func resetLearned(termIDs: [Int]) {
		for termID in termIDs {
			setLearnedTerm(termID: termID, learned: false)
			setLearnedDefinition(termID: termID, learned: false)
		}
	}
	
	func resetLearned(categoryIDs: [Int]) {
		// reset the learned status if the term appears in any of the categories
		
		let query = """
			UPDATE \(terms)
			SET
			learnedTerm = \(AnsweredState.unanswered.rawValue),
			learnedDefinition = \(AnsweredState.unanswered.rawValue)
			WHERE termID IN
			(
			SELECT DISTINCT \(assignedCategories).termID
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE \(queries.categoryString(categoryIDs: categoryIDs))
			)
			"""
		
		myDB.executeStatements(query)
	}
	
	func getTermIDsAvailableToLearn (categoryIDs: [Int], numberOfTerms: Int, showFavoritesOnly: Bool) -> [Int] {
		// These are term where learnedTerm && learnedDefinition != true
		
		let query = """
			SELECT DISTINCT \(terms).termID
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE \(queries.categoryString(categoryIDs: categoryIDs))
			AND (learnedTerm = 0 OR learnedDefinition = 0)
			\(queries.showFavoritesOnly(show: showFavoritesOnly))
			ORDER BY RANDOM ()
			\(queries.limitToString(limit: numberOfTerms))
			"""
		
		var ids = [Int]()
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				let id = Int(resultSet.int(forColumnIndex: 0))
				ids.append(id)
			}
		}
		
		return ids
		
	}
	
	func getLearnedTermsCount (categoryIDs: [Int], showFavoritesOnly: Bool) -> Int {
		
		let query = """
			SELECT COUNT (*) FROM
			(
			SELECT DISTINCT \(terms).termID
			FROM \(terms)
			JOIN \(assignedCategories)
			ON \(terms).termID = \(assignedCategories).termID
			WHERE \(queries.categoryString(categoryIDs: categoryIDs))
			AND (learnedTerm = 1 AND learnedDefinition = 1)
			\(queries.showFavoritesOnly(show: showFavoritesOnly))
			)
			"""
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		} else {
			print("fatal error making result set in getLearnedTermsCount")
		}
		
		return count
	}
	
	
	// MARK: - Questions related functions
	
	func saveAnsweredStatus (question: Question) {
		
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
			
			setAnsweredTerm(termID: question.termID, answeredState: answeredTermState)
			
		case .definition:
			
			var answeredDefinitionState = AnsweredState.unanswered
			
			if question.isAnswered() {
				if question.isCorrect() {
					answeredDefinitionState = .correct
				} else {
					answeredDefinitionState = .incorrect
				}
			}
			
			setAnsweredDefinition(termID: question.termID, answeredState: answeredDefinitionState)
			
		case .both:
			// won't ever be called
			print("fatal error don't expect questiontype = both in question controller saveAsnsweredStatus")
			return
		}
	}
	
	func setAnsweredTerm (termID: Int, answeredState: AnsweredState) {
		
		let query = "UPDATE \(terms) SET answeredTerm = \(answeredState.rawValue) WHERE (termID = \(termID))"
		
		myDB.executeStatements(query)
	}
	
	func setAnsweredDefinition (termID: Int, answeredState: AnsweredState) {
		let query = "UPDATE \(terms) SET answeredDefinition = \(answeredState.rawValue) WHERE (termID = \(termID))"
		
		myDB.executeStatements(query)
	}
	
	func resetAnswers (termIDs: [Int]) {
		for termID in termIDs {
			setAnsweredTerm(termID: termID, answeredState: .unanswered)
			setAnsweredDefinition(termID: termID, answeredState: .unanswered)
		}
	}
	
	// MARK: - test related functions
	
	func resetAnswers (categoryIDs: [Int], questionType: TermComponent) {
		
		var query: String
		
		switch questionType {
		
		case .term:
			
			query = """
				UPDATE \(terms)
				SET
				answeredTerm = \(AnsweredState.unanswered.rawValue)
				WHERE termID IN
				(
				SELECT DISTINCT \(assignedCategories).termID
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				)
				"""
			
		case .definition:
			
			query = """
				UPDATE \(terms)
				SET
				answeredDefinition = \(AnsweredState.unanswered.rawValue)
				WHERE termID IN
				(
				SELECT DISTINCT \(assignedCategories).termID
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				)
				"""
			
		case .both:
			
			query = """
				UPDATE \(terms)
				SET
				answeredTerm = \(AnsweredState.unanswered.rawValue),
				answeredDefinition = \(AnsweredState.unanswered.rawValue)
				WHERE termID IN
				(
				SELECT DISTINCT \(assignedCategories).termID
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				)
				"""
		}
		
		myDB.executeStatements(query)
	}
	
	func getAvailableQuestions (categoryIDs: [Int], numberOfQuestions: Int, questionType: TermComponent, showFavoritesOnly: Bool) -> [Question] {
		
		var query : String
		
		var questions = [Question]()
		
		switch questionType {
		
		case .term:
			
			query = """
				SELECT DISTINCT \(terms).termID, 1 as type
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND answeredTerm != \(AnsweredState.correct.rawValue)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				ORDER BY RANDOM ()
				\(queries.limitToString(limit: numberOfQuestions))
				"""
		case .definition:
			
			query = """
				SELECT DISTINCT \(terms).termID, 2 as type
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND answeredDefinition != \(AnsweredState.correct.rawValue)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				ORDER BY RANDOM ()
				\(queries.limitToString(limit: numberOfQuestions))
				"""
		case .both:
			
			query = """
				SELECT * FROM
				(
				SELECT DISTINCT \(terms).termID, 1 as type
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND answeredTerm != \(AnsweredState.correct.rawValue)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				
				UNION

				SELECT DISTINCT \(terms).termID, 2 as type
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND answeredDefinition != \(AnsweredState.correct.rawValue)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				)

				ORDER BY RANDOM ()
				\(queries.limitToString(limit: numberOfQuestions))
				"""
		}
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			while resultSet.next() {
				
				let termID = Int(resultSet.int(forColumnIndex: 0))
				let type = Int(resultSet.int(forColumnIndex: 1))
				var q : Question
				
				
				if type == 1 {
					
					q = makeTermQuestion(termID: termID, randomizeAnswers: true)
					
				} else {
					
					q = makeDefinitionQuestion(termID: termID, randomizeAnswers: true)
				}
				
				questions.append(q)
			}
		}
		
		return questions
	}

	// MARK: - counts
	
	func getTotalQuestionsCount (categoryIDs: [Int], questionType: TermComponent, showFavoritesOnly: Bool) -> Int {
		
		switch questionType {
		
		case .term, .definition:
			
			return tcTB.getTermCount(categoryIDs: categoryIDs, showFavoritesOnly: showFavoritesOnly)
			
		case .both:
			return tcTB.getTermCount(categoryIDs: categoryIDs, showFavoritesOnly: showFavoritesOnly) *  2
		}
		
	}
	
	func getCorrectQuestionsCount  (categoryIDs: [Int], questionType: TermComponent, showFavoritesOnly: Bool) -> Int {
		
		var query : String
		
		switch questionType {
		
		case .term:
			
			query = """
				SELECT COUNT (*) FROM
				(
				SELECT DISTINCT \(terms).termID
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND answeredTerm = \(AnsweredState.correct.rawValue)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				)
				"""
			
		case .definition:
			
			query = """
				SELECT COUNT (*) FROM
				(
				SELECT DISTINCT \(terms).termID
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND answeredDefinition = \(AnsweredState.correct.rawValue)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				)
				"""

		case .both:
			query = """
				SELECT COUNT (*) FROM
				(
				SELECT DISTINCT \(terms).termID
				FROM \(terms)
				JOIN \(assignedCategories)
				ON \(terms).termID = \(assignedCategories).termID
				WHERE \(queries.categoryString(categoryIDs: categoryIDs))
				AND
					(
					answeredDefinition = \(AnsweredState.correct.rawValue)
					OR answeredTerm = \(AnsweredState.correct.rawValue)
					)
				\(queries.showFavoritesOnly(show: showFavoritesOnly))
				)
				"""
		}
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		} else {
			print("fatal error making result set in getCorrectQuestionsCount")
		}
		
		return count
	}
	
}
