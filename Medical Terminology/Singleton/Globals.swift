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

var isDevelopmentMode = false   //set in the app delegate based on the pList setting

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

enum CategoryType {
	case standard
	case custom
}

// use to assign and check answeredTerm and answeredDefinition, and also for quiz answers and learning module

enum AnsweredState: Int {
	case unanswered = 0
	case correct = 1
	case incorrect = 2
}

//use for assigning and getting section categories and for talking with the database table
enum MainSectionName: String {
	case flashcards = "flashcards"
	case list = "list"
	case quiz = "quiz"
	case learning = "learning"
}

