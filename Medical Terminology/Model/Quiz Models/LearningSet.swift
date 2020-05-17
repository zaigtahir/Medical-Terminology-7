//
//  LearningSet.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

//  Class to extend QuizBase to make a LearningSet

class LearningSet: QuizBase {
    
    private let dIC = DItemController()
    
    private let itemIDs: [Int]  //to save the original itemIDs for resetting the learned items when resetting the quiz
    
    private let questionController = QuestionController()
    
    init (numberOfTerms: Int, isFavorite: Bool) {
        
        // will create a learning set with the numberOfTerms if available
        // It will select terms that are not learned yet (BOTH learnedTerm AND learnedDescription DO NOT EQUAL 1)
        
        var favoriteState = 0
        if isFavorite {
            favoriteState = 1
        }
        
        itemIDs = dIC.getItemIDs(favoriteState: favoriteState, learnedState: 0, orderBy: 2, limit: numberOfTerms)
        
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
     Will create a copy of the question and clear the learnedTerm and learnedDefinition and insert it as a new question in the masterList "interval" distance away
     or at the end of the list if there aren't enough
     
     Requeueing will always be into the master list as only the last question in the active list can be viewed in the unanswered state! THINK about this yet
     
     reset the value of learnedDefinition or the learnedTerm in the db to false depending on type of this question
     */
    func requeueQuestion (questionIndex: Int) {
        
        let originalQuestion = activeQuestions[questionIndex]
        
        if originalQuestion.questionType == .term {
            if originalQuestion.learnedTermForItem == true {
                //set to false in db
                print("learningSet resetting learned term = 0")
                dIC.saveLearnedTerm(itemID: originalQuestion.itemID, learnedState: false)
            }
        } else {
            //it is definition type question
            if originalQuestion.learnedDefinitionForItem == true {
                //set to false in db
                dIC.saveLearnedDefinition(itemID: originalQuestion.itemID, learnedState: false)
                print("learningSet resetting learned definition = 0")
            }
        }
        
        let questionCopy = activeQuestions[questionIndex].getCopy()
        
        questionCopy.resetQuestion()
        
        let interval = myConstants.requeueInterval
        
        //get the max index this can be inserted into
        
        var insertIndex = min(interval, masterList.count - 1)
        
        if insertIndex < 0 {
            //in case the masterList has only one items
            insertIndex = 0
        }
        
        masterList.insert(questionCopy, at: insertIndex)
        
        
    }
    
    //use this function to requeue a correctly answered question
    //add the question to the stack at the back
    //clear the database of learned status
    
    func selectAnswerToQuestion (questionIndex: Int, answerIndex: Int) {
        
        let question = activeQuestions[questionIndex]
        
        questionController.selectAnswer(question: question, answerIndex: answerIndex)
        
        //save learned state
        questionController.saveLearnedStatus(question: question)
        
        //requeue the question if the answer is wrong
        if !question.isCorrect() {
            requeueQuestion(questionIndex: questionIndex)
        }
        
        //append question from masterlist to the active list
        moveQuestion()
        
    }
    
    private func getUniqueActiveQuestionsItemIDs () -> [Int] {
        //used for learning set
        
        var itemIDs = [Int]()
        
        for q in activeQuestions {
            itemIDs.append(q.itemID)
        }
        
        return Array(Set(itemIDs))  //will only return unique IDs
        
    }
    
    /*
     will return the number questions learned in the active questions array
     learned count is items that ther person correctly got the term AND the definition
     */
    func getLearnedTermsCount () -> Int {
        
        let itemIDs = getUniqueActiveQuestionsItemIDs()
        
        var learned = 0
        
        for itemID in itemIDs {
            
            let item = dIC.getDItem(itemID: itemID)
            if item.learnedTerm && item.learnedDefinition {
                learned += 1
            }
            
        }
        
        return learned
        
    }
    
    /*
     will return the number questions learned in the active questions array
     learned count is items that ther person correctly got the term OR the definition
     */
    func getAnsweredQuestionsCount () -> Int {
        let itemIDs = getUniqueActiveQuestionsItemIDs()
        
        var answered = 0
        
        for itemID in itemIDs {
            
            let item = dIC.getDItem(itemID: itemID)
            if item.learnedTerm || item.learnedDefinition {
                answered += 1
            }
        }
        
        return answered
    }
    
    func resetLearningSet () {
        
        //reset any learned values in the DB
        dIC.clearLearnedItems(itemIDs: itemIDs)
        
        //reload the set with the original questions
        reset()
        
    }
    
    
}
