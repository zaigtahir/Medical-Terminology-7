//
//  QuizSet.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

//  Class to extend the QuizBase to function as a QuizSet

let questionController = QuestionController()

// to use when making questions
struct QuestionInfo {
    let itemID: Int
    let type: Int   //1 term type   //2 definition type
}

class QuizSet: QuizBase {
    
    private let dIC = DItemController()
    
    private let itemIDs: [Int]  //to save the original itemIDs for resetting the learned items when resetting the quiz
    
    private let questionController = QuestionController()
    
    init (numberOfQuestions: Int, favoriteState: Int, questionTypes: QuestionsType) {
        
        // will create a quizSet set with the numberOfQuestions if available
        
        // It will only select to make questions with items that answeredState is not 2
        
        // So when making both, you could have one question for term and the other for definition
        
        var favoriteStateQueryPortion: String
        var questionsForArray = [QuestionInfo]()
        var fullQuery: String
        var questions = [Question]()
        
        switch favoriteState {
            
        case 0:
            favoriteStateQueryPortion = " isFavorite = 0 "
        case 1:
            favoriteStateQueryPortion = " isFavorite = 1 "
        default:
            favoriteStateQueryPortion = " isFavorite < 2 "  // will select both 0 and 1
        }
        
        switch questionTypes {
            
        case .random:
            fullQuery = """
            SELECT * FROM
            (
            SELECT itemID, 1 as type from dictionary  WHERE answeredTerm !=2 AND \(favoriteStateQueryPortion)
            UNION
            SELECT itemID, 2 as type from dictionary  WHERE answeredDefinition !=2  AND \(favoriteStateQueryPortion)
            )
            ORDER BY RANDOM() LIMIT \(numberOfQuestions)
            """
            
        case .term:
            fullQuery = " SELECT itemID, 1 as type from dictionary  WHERE answeredTerm !=2 AND \(favoriteStateQueryPortion) ORDER BY RANDOM() LIMIT \(numberOfQuestions) "
        
        default:
            fullQuery = " SELECT itemID, 2 as type from dictionary  WHERE answeredDefinition !=2 AND \(favoriteStateQueryPortion) ORDER BY RANDOM() LIMIT \(numberOfQuestions) "
            
        }
        
        if let resultSet = myFMDB.fmdb.executeQuery(fullQuery, withParameterDictionary: nil) {
            while resultSet.next() {
                let itemID = Int(resultSet.int(forColumn: "itemID"))
                let type = Int(resultSet.int(forColumn: "type"))
                questionsForArray.append(QuestionInfo(itemID: itemID, type: type))
            }
        }
        
        // now make them in to questions
        
        for q in questionsForArray {
            
            var question: Question
            
            if q.type == 1 {
                // need term type question
                question = questionController.makeTermQuestion(itemID: q.itemID, randomizeAnswers: true)
            } else {
                question = questionController.makeDefinitionQuestion(itemID: q.itemID, randomizeAnswers: true)
            }
            
            questions.append(question)
            
        }
        
        self.itemIDs = [1,2,3]  //just placeholder
        
        super.init(originalQuestions: questions)
        
    }
    
    func selectAnswerToQuestion (questionIndex: Int, answerIndex: Int) {
        
        //TODO: customize to question right now this is from saving learning function
        
        let question = activeQuestions[questionIndex]
        
        questionController.selectAnswer(question: question, answerIndex: answerIndex)
        
        //save learned state
        questionController.saveAnsweredStatus(question: question)
        
        //append question from masterlist to the active list
        moveQuestion()
        
    }
    
    func resetQuizSet () {
        
        dIC.clearAnsweredItems(itemIDs: itemIDs)
        
        reset()
        
    }
    
}
