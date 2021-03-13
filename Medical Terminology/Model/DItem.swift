//
//  Flashcard.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 10/12/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

// This is the basic Q&A item

import Foundation
import AVFoundation
import UIKit

class DItem {
    
    var itemID: Int = 0
    var term: String = "none loaded"
    var definition: String = "none loaded"
    var example: String = "none loaded"
    var categoryID: Int = 0
    var audioFile: String = "none loaded"
	
    var isFavorite: Bool = false
	
    var learnedTerm: Bool = false
    var learnedDefinition: Bool = false
	
    var answeredTerm: Int = 0  // 0 = unanswered, 1 = correctly answered, 2 = answered wrong
    var answeredDefinition: Int = 0 // 0 = unanswered, 1 = correctly answered, 2 = answered wrong

    init () {
        // no other work to do here
    }
    
    /**
     *values*
     'answeredTerm'  0 = unanswered, 1 = correctly answered, 2 = answered wrong
     'answeredDefinition' 0 = unanswered, 1 = correctly answered, 2 = answered wrong
     */
    convenience init (itemID: Int, term: String, definition: String, example: String, categoryID: Int, audioFile: String, isFavorite: Bool, learnedTerm: Bool, learnedDefinition: Bool, answeredTerm: Int, answeredDefinition: Int  ) {
        
        self.init()
        
        self.itemID = itemID
        self.term = term
        self.definition = definition
        self.example = example
        self.categoryID = categoryID
        self.audioFile = audioFile
        self.isFavorite = isFavorite
        self.learnedTerm = learnedTerm
        self.learnedDefinition = learnedDefinition
        self.answeredTerm = answeredTerm
        self.answeredDefinition = answeredDefinition
        
    }
}
