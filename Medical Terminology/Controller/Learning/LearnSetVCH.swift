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
            
            return "You have answered \n\(learningSet.getAnsweredQuestionsCount()) of \(learningSet.getTotalQuestionCount()) questions correctly!"
            
        default:
            return "You're done! You got all \(learningSet.getTotalQuestionCount()) questions correct!."
            
        }
        
    }
    
    // us for progress bar
    func getProgress () -> (Float) {
        return (Float(learningSet.getAnsweredQuestionsCount()) / Float(learningSet.getTotalQuestionCount()))
    }
    
    
    func configure (startNew: Bool, numberOfTerms: Int = 0, isFavorite: Bool = false) {
        
        if startNew {
            //create a new learningset
            learningSet = LearningSet(numberOfTerms: numberOfTerms, isFavorite: isFavorite)
        }
        
    }
    
    /**
     Will return true if the collection view is displaying the last card (summary)
     */
    func isAtSummary (indexPath: IndexPath) -> Bool {
        
        if (indexPath.row == learningSet.activeQuestions.count - 1) && (learningSet.masterList.count == 0) {
            
            return true
            
        } else {
            
            return false
        }
    }
    
}

