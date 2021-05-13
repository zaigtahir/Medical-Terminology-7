//
//  Globals.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

//global variables

var myDB : FMDatabase!          // serve as the global database object

let myTheme = MyTheme ()
let myConstants = MyConstants ()
let myKeys = MyKeys()

enum TermComponent: Int {
	case both = 0
	case term = 1
	case definition = 2
}

enum QuizStatus {
    case notStarted
    case inProgress
    case done
}


// use to display the category list view
enum CategoryListMode {
	case selectCategory
	case assignCategory
}

// use to display the termVC
enum TermEditMode {
	case add
	case view
}


// use to display the category or term
enum CategoryEditMode {
	case view
	case add
	case edit
	case delete
}

// use to assign and check answeredTerm and answeredDefinition, and also for quiz answers and learning module

enum AnsweredState: Int {
	case unanswered = 0
	case correct = 1
	case incorrect = 2
}

enum CategoryType : Int {
	case standard = 1	// the raw value coorelates to the db value
	case custom = 0		// the raw value coorelates to the db value
}

// used for coordinating the segue and protocol/delegate for editing fields
enum PropertyReference {
	case name
	case definition
	case description
	case example
	case myNotes
}
