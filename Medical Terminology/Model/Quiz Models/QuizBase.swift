//
//  QuizBase.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

class QuizBase {
    
    var activeQuestions = [Question]()
    
    var masterList = [Question]()
    
    var originalQuestions = [Question]()
    
    init (originalQuestions: [Question]) {
        
        //keep original question untouched and for use to reset the quiz
        
        self.originalQuestions = originalQuestions
        
        self.originalQuestions.append(Question())   //append a place holder to use as the last/summary screen
        
        self.masterList = getCopyOfQuestions(questions: self.originalQuestions)
        
        moveQuestion()
        
    }
    
    private func getCopyOfQuestions (questions: [Question]) -> [Question] {
        
        var questionsCopy = [Question]()
        
        for q in questions {
            
            questionsCopy.append(q.getCopy())
            
        }
        
        return questionsCopy
        
    }
    
    func moveQuestion () {
        //will remove the index 0 of masterList and append it to questions
        
        if masterList.count > 0 {
            
            let question = masterList.remove(at: 0)
            
            activeQuestions.append(question)
            
        }
        
    }
    
    func getQuestion (index: Int) -> Question {
        
        return activeQuestions[index]
    }
    
    func getTotalQuestionCount () -> Int {
        return originalQuestions.count - 1 //minus one to remove the summary placeholder last question
    }
    
    func getActiveQuestionsCount () -> Int {
        return activeQuestions.count
    }
    
    func isAnswered (questionIndex: Int) -> Bool {
        //return if current question is answered
        return activeQuestions[questionIndex].isAnswered()
    }
    
    func printQuestions(list: Int) {
        //list = 0 master
        //list = 1 activeQuestions
        
        var questionList = [Question]()
        
        if list == 0 {
            questionList = masterList
        } else {
            questionList = activeQuestions
        }
        
        for q in questionList {
            q.printQuestion()
        }
    }
    
    func getNumberCorrect () -> Int {
        
        var correct = 0
        
        for q in activeQuestions {
            
            if q.isAnswered() &&  q.isCorrect() {
                
                correct += 1
            }
        }
        return correct
    }
    
    func getGrade () -> (grade: String, percent: String) {
        
        let score = Float(getNumberCorrect())/Float(getTotalQuestionCount()) * 100
        
        let percent =
            String(format: "%.0f", score) //formats to zero decimal place
        
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
        
        return (grade, percent)
    }
    
    /**
     return value
     Int: 0 = not started, 1 = in progress, 2 = finished
     */
    func getQuizStatus () -> Int {
        
        
        // if first question not answered, return 0
        
        // if first question is answered, and last question is NOT answered, return 1
        
        // if last question is answered, return 2
        
        if !activeQuestions[0].isAnswered() {
            
            //first question is not answered, so quiz ia not started
            
            return 0
            
        }
        
        //here at least the first question is answered so the quiz is either in progress or complete
        
        let lastQuestion = activeQuestions[activeQuestions.count - 1]
        
        if lastQuestion.isAnswered() {
            
            return 2 //is complete
            
        } else {
            
            return 1 // is in progress
        }
    }
    
    func reset () {
        
        //remember to clear learned or answered terms in the appropriate subclass
        
        masterList = getCopyOfQuestions(questions: originalQuestions)
        
        activeQuestions = [Question]()
        
        moveQuestion()
        
    }
    
}

