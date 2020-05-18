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
    
    /*
     Create a copy of the question and
     clear the answer and learning status data in this local object (does not affect the db)
     Then move the question in interval into the master list. if the interval is too long then move
     it to the end of the list
     */
    func requeueQuestion (questionIndex: Int) {
        
        let questionCopy = activeQuestions[questionIndex].getCopy()
        questionCopy.resetQuestion()    //resets the answer and learn status
        
        if masterList.count == 0 {
            // the view is sitting showing the second to last card in active list
            // BLANK card is preloaded as a place holder for the done cell
            // nothing is in the master list
            
            // replace the BLANK card with the copy of the question
            activeQuestions.remove(at: activeQuestions.count - 1)   // remove the last item
            activeQuestions.append(questionCopy)    //append the question
            
            // now ADD a BLANK question to the master list
            masterList.append(Question())
            
        } else {
            // get the max index this can be inserted into in the masterList
            let interval = myConstants.requeueInterval
            
            var insertIndex = min(interval, masterList.count - 1)
            
            if insertIndex < 0 {
                //in case the masterList has only one items
                insertIndex = 0
            }
            
            masterList.insert(questionCopy, at: insertIndex)
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
    
    func addFeedbackRemarks (question: Question) {
        //will add feedback to question based on answered/right/wrong status
        
        if question.isAnswered() {
            if question.isCorrect() {
                //is correct
                question.feedbackRemarks = myConstants.feedbackAnsweredCorrect.randomElement()!
            } else {
                //is wrong
                question.feedbackRemarks = myConstants.feedbackAnsweredWrong.randomElement()!
            }
        } else {
            question.feedbackRemarks = myConstants.feedbackNotAnswered
        }
    }
        
    func getQuizStatus () -> QuizStatus {
        
        if !activeQuestions[0].isAnswered() {
            //first question is not answered, so quiz ia not started
            return .notStarted
        }
        
        // is last question answered? Last question is activeList.count - 2 as the very last one is a blank place holder
        let isLastQuestionAnswered = activeQuestions[activeQuestions.count - 2].isAnswered()
        
        if masterList.count == 0 && isLastQuestionAnswered {
            return .done
        } else {
            return .inProgress
        }
        
    }
    
    func reset () {
        
        //remember to clear learned or answered terms in the appropriate subclass
        
        masterList = getCopyOfQuestions(questions: originalQuestions)
        
        activeQuestions = [Question]()
        
        moveQuestion()
        
    }
    
}

