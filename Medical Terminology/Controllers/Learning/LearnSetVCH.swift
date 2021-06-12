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
    
    
    /**
     Will return true if the collection view is displaying the last card (summary)
     */
    func isAtSummary (indexPath: IndexPath) -> Bool {
        
        let row = indexPath.row
        
        if (row == learningSet.activeQuestions.count - 1) && (learningSet.masterList.count == 0) {
            return true
        } else {
            return false
        }
    }
    
}


