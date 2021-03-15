//
//  Globals.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

//global variables

var myDB : FMDatabase!          //serve as the global database object
let dbFilename = "Medical Terminology"
let dbFileExtension = "db"
var isDevelopmentMode = false   //set in the app delegate based on the pList setting

let audioFolder = "Audio"       //the subfolder in bundle that will hold the audio files

let myTheme = MyTheme ()
let myConstants = MyConstants ()
let myKeys = MyKeys()

enum FlashcardViewMode {
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

enum CategoryViewMode {
	case selectCategory
	case assignCategory
}

// raw type for this enum as i will use it for the database too

enum CategoryType: Int {
	case standard = 0
	case custom = 1
}

// use to assign and check answeredTerm and answeredDefinition, and also for quiz answers and learning module

enum AnsweredState: Int {
	case unanswered = 0
	case correct = 1
	case incorrect = 2
}

