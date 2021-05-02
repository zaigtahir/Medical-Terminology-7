//
//  QuestionController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/20/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

class QuestionController2 {
	
	// MARK: shorter table names to make things easier
	let terms = myConstants.dbTableTerms
	let assignedCategories = myConstants.dbTableAssignedCategories
	let categories = myConstants.dbTableCategories2
	
	let tc = TermController()
	
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
		
		let query = "SELECT DISTINCT term, REPLACE (name, '-' , '') AS noHyphenInName FROM \(terms) WHERE name != \(notIncluding) AND noHyphenInName != \(notIncluding) ORDER BY RANDOM () LIMIT 3"
		
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
		
		let query = "SELECT DISTINCT definition FROM \(terms) WHERE definition != \(notIncluding) ORDER BY RANDOM () LIMIT 3"
		
		print("question controller get3DefinitionAnswers query: \(query)")
		
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			
			while resultSet.next() {
				let definition = resultSet.string(forColumn: "definition") ?? ""
				definitions.append(definition)
			}
		}
		
	
		return definitions
	}
	
	// MARK: - WHY do i just have updating learned status here????? this probably belongs in the LEARNING SET
	
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

}

class QuestionController {
    
    let dIC = DItemController()
    
    func makeTermQuestion (itemID: Int, randomizeAnswers: Bool) -> Question {
        // question is term, answers are definitions which do not include the definition in dItem
        
        let dItem = dIC.getDItem(itemID: itemID)
        
        let question = Question ()
        
        question.questionType = .term
        question.itemID = dItem.itemID
        question.questionText = dItem.term
        question.answers[3].answerText = dItem.definition
        question.answers[3].isCorrect = true
        
        //now add the answers
        let otherAnswers = get3DefinitionAnswers(notIncluding: question.answers[3].answerText)
        
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
    
    func makeDefinitionQuestion (itemID: Int, randomizeAnswers: Bool) -> Question {
        // question is definition, anwers are terms which do not include the term in dItem
        
        let dItem = dIC.getDItem(itemID: itemID)
        
        let question = Question ()
        question.questionType = .definition
        question.itemID = dItem.itemID
        
        
        question.itemID = dItem.itemID
        question.questionText = dItem.definition
        
        question.answers[3].answerText = dItem.term
        question.answers[3].isCorrect = true
        
        //now add the answers
        let otherAnswers = get3TermAnswers(notIncluding: dItem.term)
        
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
    
    func makeRandomTypeQuestion (itemID: Int, randomizeAnswers: Bool) -> Question {
        
        let r = Int.random(in: 0...1)
        
        if (r == 0) {
            
            return makeDefinitionQuestion(itemID: itemID, randomizeAnswers: randomizeAnswers)
            
        } else {
            
            return makeTermQuestion (itemID: itemID, randomizeAnswers: randomizeAnswers)
            
        }
        
        
    }
    
    func makeSampleQuestion () -> Question {
        let question = Question()
        question.itemID = 0
        
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
    
    func get3TermAnswers(notIncluding: String) -> [String] {
        //return 3 random terms from the full list
        //if empty, return empty array
        
        var terms = [String]()
        
        let query = "SELECT DISTINCT term, termDisplay FROM dictionary  WHERE term != ? AND termDisplay != ? ORDER BY RANDOM() LIMIT 3"
        
        if let resultSet = myDB.executeQuery(query, withArgumentsIn: [notIncluding, notIncluding])
        {
            
            while resultSet.next() {
                var term = resultSet.string(forColumn: "term") ?? "default"
                let termDisplay = resultSet.string(forColumn: "termDisplay") ?? "default"
                
                //replace term with termDisplay if there is something in term display
                if termDisplay.isEmpty == false {
                    term = termDisplay
                    
                }
                terms.append(term)
            }
        }
        
        return terms
    }
    
    func get3DefinitionAnswers(notIncluding: String) -> [String]{
        //return 3 random definitions from the full list
        //if empty, return empty array
        
        var definitions = [String]()
        
        let query: String = "SELECT DISTINCT Definition FROM dictionary  WHERE definition != ? ORDER BY RANDOM() LIMIT 3"
        
        if let resultSet = myDB.executeQuery(query, withArgumentsIn: [notIncluding]) {
            
            while resultSet.next() {
                
                let definition = resultSet.string(forColumn: "definition")  ?? "default"
                definitions.append(definition)
            }
        }
        
        return definitions
    }
    
    func selectAnswer (question: Question, answerIndex: Int) {
		print("selectAnswer in QuestionController")
        question.selectAnswerIndex(answerIndex: answerIndex)
        
        if question.isCorrect() {
            
            if question.questionType == .term {
                
                question.learnedTermForItem = true
                
            } else {
                
                question.learnedDefinitionForItem = true
            }
        }
        
    }
    
    func saveLearnedStatus (question: Question) {
        
        if question.questionType == .term
        {
            
            dIC.saveLearnedTerm(itemID: question.itemID, learnedState: question.learnedTermForItem)
            
        } else {
            
            dIC.saveLearnedDefinition(itemID: question.itemID, learnedState: question.learnedDefinitionForItem)
            
        }
        
    }
    
    func saveAnsweredStatus (question: Question) {
        
        //answeredTerm: 0 = not answered, 1 = WRONG, 2 = CORRECT
        //answeredDefinition: 0 = not answered, 1 = WRONG, 2 = CORRECT
        
        if question.questionType == .term {
            
            var answerTermState = 0
            
            if question.isAnswered() {
                
                if question.isCorrect() {
                    
                    answerTermState = 2
                    
                } else {
                    
                    answerTermState = 1
                    
                }
            }
            
            
            dIC.saveAnsweredTerm(itemID: question.itemID, answerState: answerTermState)
            
        } else {
            
            var answerDefinitionState = 0
            
            if question.isAnswered() {
                
                if question.isCorrect() {
                    
                    answerDefinitionState = 2
                    
                } else {
                    
                    answerDefinitionState = 1
                    
                }
            }
            
            dIC.saveAnsweredDefinition(itemID: question.itemID, answerState: answerDefinitionState)
            
        }
    }
    
    func isLearned (question: Question) -> Bool {
        //will return true if both learned term and learned defintion are true
        
        let item = dIC.getDItem(itemID: question.itemID)
        
        return item.learnedDefinition && item.learnedTerm
        
        
    }
    
}
