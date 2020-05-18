//
//  Question.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

//   Reminder: use the question controller to select an answer for the question as the questionController will save the learned state in the DB and also

import Foundation

class Question {
    //blank questionText
    var questionText: String = ""
    var answers = [Answer]()
    var questionType : QuestionsType = .term
    var itemID = 0
    
    var learnedTermForItem = false
    var learnedDefinitionForItem = false
    var showAnswer = false
    var showAgain = false
    var feedbackRemarks = myConstants.feedbackNotAnswered    //use to store text to show on the learning cards or quiz cards
    
    //initial non selected state. Use to check if this is answered or unanswered
    private var selectedAnswerIndex: Int = -1
    
    
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
        
        print("itemID: \(itemID)")
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
    
    //TODO move this and the other remarks out of here!!!!!
    func getLearningRemarks () -> String {
        
        //will return a random phrase of correct or incorrect answers
        
        let correctFeedback = ["Yes! You got it!", "Correct! Great job!", "You are right!", "Awesome! You're right!"]
        
        let wrongFeedback = ["Incorrect! You'll see this again", "Incorrect! Keep going!", "Incorrect! Don't give up!"]
        
        if isAnswered() {
            if isCorrect() {
                return correctFeedback.randomElement()!
            } else {
                return wrongFeedback.randomElement()!
            }
        } else {
            return "Select An Answer"
        }
        
        
    }
    
    func getQuizAnswerRemarks () -> String {
        
        //will return feedback based on the status of the answer
        
        let correctFeedback = ["Yes! You got it!", "Correct! Great job!", "You are right!", "Awesome! You're right!"]
        
        let wrongFeedback = ["Incorrect"]
        
        if isAnswered() {
            if isCorrect() {
                return correctFeedback.randomElement()!
            } else {
                return wrongFeedback.randomElement()!
            }
        } else {
            return "Not answered"
        }

    }
    
    func getCopy () -> Question {
        
        let question = Question ()
        
        question.questionText = self.questionText
        question.answers = self.answers
        question.selectedAnswerIndex = self.selectedAnswerIndex
        question.itemID = self.itemID
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
        feedbackRemarks = ""
    }
}


