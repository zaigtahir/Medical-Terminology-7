//
//  Answer.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

class Answer {
    var answerText: String
    var isCorrect: Bool
    
    init (answerText: String, isCorrect: Bool) {
        self.answerText = answerText
        self.isCorrect = isCorrect
    }

}
