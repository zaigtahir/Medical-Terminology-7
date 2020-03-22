//
//  QuizSetVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

import UIKit

class QuizSetVCH {
    
    var quizSet: QuizSet!      //set this in seque
    
    func getGradeLabelText() -> String {
        
        let result = quizSet.getGrade()
        
        return "Final Grade: \(result.grade)"
    }
    
    func getResultsLabeText () -> String {
        
        let result = quizSet.getGrade()
        
        let correct = quizSet.getNumberCorrect()
        
        let total = quizSet.getTotalQuestionCount()
        
        return "You got \(correct) of \(total) or (\(result.percent)%) correct."
        
        
    }
    
    
    /**
     Will return true if the collection view is displaying the last card (summary)
     */
    func isAtSummary (indexPath: IndexPath) -> Bool {
        
        if indexPath.row == quizSet.originalQuestions.count - 1  {
            
            return true
            
        } else {
            
            return false
        }
    }
}
