//
//  Globals.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

//global variables

let myTheme = MyTheme ()
let myConstants = MyConstants ()
let myFMDB = MyFMDB()
let myKeys = MyKeys()

let testVariable: String = "test"

enum FlashCardViewMode {
    case both
    case term
    case definition
}

enum QuestionsType {
    case term
    case definition
    case random
}

enum QuizStatus {
    case notStarted
    case inProgress
    case done
}
