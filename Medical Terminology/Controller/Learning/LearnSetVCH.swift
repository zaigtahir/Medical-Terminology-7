//
//  LearnVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/12/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class LearningSetVCH {
    
    var learningSet: LearningSet!   //configure with configure function in when setting up segue
    
    func getProgressLabelText () -> String {
        
        let learningStatus = learningSet.getQuizStatus()
        
        switch learningStatus {
            
        case 0, 1:
            // case 0: not started
            // case 1: started but not done
            
            return "You have answered Correct Number of Total Number questions correctly!"
            
        default:
            return "You're done! You got all Total Number questions correct!."
            
        }
        
    }
    
    // us for progress bar
    func getProgress () -> (Float) {
        return 0.5
        //return (Float(learningSet.getAnsweredQuestionsCount()) / Float(learningSet.getTotalQuestionCount()))
    }
    
    /**
     Will return true if the collection view is displaying the last card (summary)
     */
    func isAtSummary (indexPath: IndexPath) -> Bool {
        
        return false
        
        let row = indexPath.row
        print("isAtSummary: row \(row)")
        print("isAtSummary: activeQuestions.count = \(learningSet.activeQuestions.count)")
        
        for q in learningSet.activeQuestions {
            q.printQuestion()
        }
        
        if (row == learningSet.activeQuestions.count - 1) && (learningSet.masterList.count == 0) {
            
            return true
            
        } else {
            
            return false
        }
    }

}


