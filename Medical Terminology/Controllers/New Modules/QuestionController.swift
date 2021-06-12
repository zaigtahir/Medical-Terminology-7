//
//  QuestionController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

/**
This class will handle items related to getting and saving items related to questions, quiz and learning set
*/

class QuestionController {
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	
	let tc = TermController()
	
	// MARK: shorter table names to make things easier
	let assignedCategories = myConstants.dbTableAssignedCategories
	
	/// question is term, answers are definitions which do not include the definition in the term
	func makeTermQuestion (termID: Int, randomizeAnswers: Bool) -> Question {
		
		let term = tc.getTerm(termID: termID)
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
		
		let term = tc.getTerm(termID: termID)
		
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
	
	// MARK: - learning related functions
	
	func isLearned (categoryID: Int, termID: Int) -> Bool {
		//will return true if both learned term and learned defintion are true
		
		let query = """
					SELECT COUNT (*) FROM \(assignedCategories)
					WHERE categoryID = \(categoryID)
					AND termID = \(termID)
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
	
	func saveLearnedStatus (categoryID: Int, question: Question) {
		
		if question.questionType == .term
		
		{
			setLearnedTerm (categoryID: categoryID, termID: question.termID, learned: question.learnedTermForItem)
			
		} else {
			
			setLearnedDefinition(categoryID: categoryID, termID: question.termID, learned: question.learnedDefinitionForItem)
		}
		
	}
	
	func setLearnedTerm (categoryID: Int, termID: Int, learned: Bool) {
		
		var lt = 0
		if learned {
			lt = 1
		}
		
		let query = "UPDATE \(assignedCategories) SET learnedTerm = \(lt) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		
		myDB.executeStatements(query)
		
	}
	
	func setLearnedDefinition  (categoryID: Int, termID: Int, learned: Bool) {
		
		var ld = 0
		if learned {
			ld = 1
		}
		
		let query = "UPDATE \(assignedCategories) SET learnedDefinition = \(ld) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		
		myDB.executeStatements(query)
		
	}
	
	/**
	reset all these terms in this category
	*/
	func resetLearned(categoryID: Int, termIDs: [Int]) {
		for termID in termIDs {
			setLearnedTerm(categoryID: categoryID, termID: termID, learned: false)
			setLearnedDefinition(categoryID: categoryID, termID: termID, learned: false)
		}
	}
	
	/**
	reset all learned in this category
	*/
	func resetLearned(categoryID: Int) {
		
		let query = "UPDATE \(assignedCategories) SET learnedTerm = \(AnsweredState.unanswered.rawValue), learnedDefinition = \(AnsweredState.unanswered.rawValue) WHERE categoryID = \(categoryID)"
		
		myDB.executeStatements(query)
	}
		
	func getTermIDsAvailableToLearn (categoryID: Int, numberOfTerms: Int, favoritesOnly: Bool) -> [Int] {
		// These are term where learnedTerm && learnedDefinition != true
		
		var favoriteString = ""
		if favoritesOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		let query = """
		SELECT termID from \(assignedCategories)
		WHERE categoryID  = \(categoryID)
		\(favoriteString)
		AND (learnedTerm = 0 OR learnedDefinition = 0)
		ORDER BY RANDOM ()
		LIMIT \(numberOfTerms)
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
	
	func getLearnedTermsCount (categoryID: Int, favoritesOnly: Bool) -> Int {
		
		var favoriteString = ""
		if favoritesOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		let query = """
		SELECT COUNT (*) FROM \(assignedCategories)
		WHERE categoryID = \(categoryID)
		AND (learnedTerm = 1 AND learnedDefinition = 1)
		\(favoriteString)
		"""
	
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		} else {
			print("fatal error making result set in getQuestionsAvailableCount")
		}
		
		return count
	}
	
	// MARK: - quiz related functions
	
	func saveAnsweredStatus (categoryID: Int, question: Question) {
		
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
			
			setAnsweredTerm(categoryID: categoryID, termID: question.termID, answeredState: answeredTermState)
			
		case .definition:
			
			var answeredDefinitionState = AnsweredState.unanswered
			
			if question.isAnswered() {
				if question.isCorrect() {
					answeredDefinitionState = .correct
				} else {
					answeredDefinitionState = .incorrect
				}
			}
			
			setAnsweredDefinition(categoryID: categoryID, termID: question.termID, answeredState: answeredDefinitionState)
			
		case .both:
			// won't ever be called
			print("fatal error don't expect questiontype = both in question controller saveAsnsweredStatus")
			return
		}
	}
	
	func setAnsweredTerm (categoryID: Int, termID: Int, answeredState: AnsweredState) {
		
		let query = "UPDATE \(assignedCategories) SET answeredTerm = \(answeredState.rawValue) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		
		myDB.executeStatements(query)
	}
	
	func setAnsweredDefinition (categoryID: Int, termID: Int, answeredState: AnsweredState) {
		let query = "UPDATE \(assignedCategories) SET answeredDefinition = \(answeredState.rawValue) WHERE (termID = \(termID) AND categoryID = \(categoryID))"
		
		myDB.executeStatements(query)
	}
	
	func resetAnswers (categoryID: Int, termIDs: [Int]) {
		for termID in termIDs {
			setAnsweredTerm(categoryID: categoryID, termID: termID, answeredState: .unanswered)
			setAnsweredDefinition(categoryID: categoryID, termID: termID, answeredState: .unanswered)
		}
	}
	
	func resetAnswers (categoryID: Int, questionType: TermComponent) {
		
		var query: String
		
		switch questionType {
		
		case .term:
			query = "UPDATE \(assignedCategories) SET answeredTerm = \(AnsweredState.unanswered.rawValue) WHERE categoryID = \(categoryID)"
			
		case .definition:
			query = "UPDATE \(assignedCategories) SET answeredDefinition = \(AnsweredState.unanswered.rawValue) WHERE categoryID = \(categoryID)"
			
		case .both:
			query = "UPDATE \(assignedCategories) SET answeredTerm = \(AnsweredState.unanswered.rawValue), answeredDefinition = \(AnsweredState.unanswered.rawValue) WHERE categoryID = \(categoryID)"
			
		}
		
		myDB.executeStatements(query)
	}
	
	/// return array of ids where answeredTerm = unanswered OR incorrect
	func getAvilableTermQuestions (categoryID: Int, numberOfQuestions: Int, favoriteOnly: Bool) -> [Question] {
		
		var questions = [Question]()
		
		var favoriteString = ""
		if favoriteOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		
		let query = """
			SELECT termID FROM \(assignedCategories)
			WHERE categoryID = \(categoryID) AND answeredTerm != \(AnsweredState.correct.rawValue) \(favoriteString)
			ORDER BY RANDOM ()
			LIMIT \(numberOfQuestions)
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
	func getAvailableDefinitionQuestions (categoryID: Int, numberOfQuestions: Int, favoriteOnly: Bool) -> [Question]  {
		
		var questions = [Question]()
		
		var favoriteString = ""
		if favoriteOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		
		let query = """
			SELECT termID FROM \(assignedCategories)
			WHERE categoryID = \(categoryID) AND answeredDefinition != \(AnsweredState.correct.rawValue) \(favoriteString)
			ORDER BY RANDOM ()
			LIMIT \(numberOfQuestions)
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
	func getAvailableQuestions (categoryID: Int, numberOfQuestions: Int, favoritesOnly: Bool) -> [Question]  {
		
		var questions = [Question]()
		
		var favoriteString = ""
		if favoritesOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		let query = """
		SELECT * FROM
		(
		SELECT termID, 1 as type from \(assignedCategories)  WHERE categoryID = \(categoryID) AND  answeredTerm != \(AnsweredState.correct.rawValue) \(favoriteString)
		UNION
		SELECT termID, 2 as type from \(assignedCategories)  WHERE categoryID = \(categoryID) AND  answeredDefinition != \(AnsweredState.correct.rawValue) \(favoriteString)
		)
		ORDER BY RANDOM()
		LIMIT \(numberOfQuestions)
		"""
		
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
	
	func getTotalQuestionsCount (categoryID: Int, questionType: TermComponent, favoriteOnly: Bool) -> Int {
		
		switch questionType {
		
		case .term, .definition:
			return tc.getCount2(categoryID: categoryID, favoritesOnly: favoriteOnly)
			
		case .both:
			return tc.getCount2(categoryID: categoryID, favoritesOnly: favoriteOnly) * 2
		}
		
	}
	
	func getCorrectQuestionsCount  (categoryID: Int, questionType: TermComponent, favoriteOnly: Bool) -> Int {
		
		var favoriteString = ""
		if favoriteOnly {
			favoriteString = " AND isFavorite = 1"
		}
		
		var query : String
		
		switch questionType {
		
		case .term:
			query = """
				SELECT COUNT (*) termID FROM \(assignedCategories)
				WHERE answeredTerm = \(AnsweredState.correct.rawValue)
				\(favoriteString)
				"""
		case .definition:
			query = """
				SELECT COUNT (*) termID FROM \(assignedCategories)
				WHERE answeredDefinition = \(AnsweredState.correct.rawValue)
				\(favoriteString)
				"""
		case .both:
			query = """
				SELECT COUNT (*) termID FROM \(assignedCategories)
				WHERE answeredTerm = \(AnsweredState.correct.rawValue)
				OR answeredDefinition = \(AnsweredState.correct.rawValue)
				\(favoriteString)
				"""
		}
		
		var count = 0
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			count = Int (resultSet.int(forColumnIndex: 0))
		} else {
			print("fatal error making result set in getQuestionsAvailableCount")
		}
		
		return count
	}

}
