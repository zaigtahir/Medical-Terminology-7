//
//  MyConstants.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/15/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class MyConstants {
	
	// database related names
	let dbFilename = "Medical Terminology"
	let dbFileExtension = "db"
	
	let dbTableTerms = "terms"
	let dbTableAssignedCategories = "assignedCategories"
	let dbTableCategories2 = "categories2"
	let dbTableMainSectionCategories = "mainSectionCategories"
	
	let dbTableMain = "dictionary"
	let dbTableUser = "assignCategories"

	let dbTableCatetories = "categories"
	
	let dbCustomTermStartingID = 100000 // plan to remove
	let dbCustomCategoryStartingID = 1000 // plan to remove

	let audioFolder = "Audio"       //the subfolder in bundle that will hold the audio files
	
    // app and website information
    let appWebsite = "https://www.theappgalaxy.com/prefixesandsuffixes.html"
    let companyWebsite = "https://theappgalaxy.com"
    let copyrightNotice = "Copyright: 2021 by Dr. Tahir"
    let appEmail = "support@theappgalaxy.com"
    let appTitle = "Practical Medical Terminology"
    
    let noFavoritesAvailableText = "There are no favorites available to show"
	
	// segues
	let segueFlashcardOptions = "segueFlashCardOptions"
	let segueSelectCatetory = "segueSelectCategory"
	let segueAssignCategory = "segueAssignCategory"
	let segueCategory = "segueCategory"
	
	let segueValidationVC = "segueValidationVC"
	
    // question feedback remarks
    let feedbackNotAnswered = "Select An Answer"
    let feedbackAnsweredCorrect = ["Yes! You got it!", "Correct! Great job!", "You are right!", "Awesome! You're right!"]
    let feedbackAnsweredWrong = ["Incorrect"]
    
    // do not change these numbers. They are used as indexes of arrays too
	
	// MARK: need to make this an literal enum
	
    let listType_Full = 0
    let listType_Favorite = 1
    let listType_Random = 2
    let listType_Sample = 3
    
    let button_cornerRadius = CGFloat(integerLiteral: 5)
    let layout_cornerRadius = CGFloat(integerLiteral: 10)
    let layout_sideMargin = CGFloat(integerLiteral: 20)
    let layout_topBottomMargin = CGFloat(integerLiteral: 10)
	
    let requeueInterval = 7 //interval to requeue a question in a learning set if it is answered wrong
}
