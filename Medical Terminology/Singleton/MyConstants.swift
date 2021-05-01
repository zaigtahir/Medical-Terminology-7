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
	
	let dbCategoryAllTermsID = 1
	let dbCategoryMyTermsID = 2

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
    
	
	// no terms messages
	let noTermsHeading = "No Terms To Show"
	let noTermsSubheading = "There are no terms in this category. When you add terms to this category, they will show here."
	let noFavoriteTermsHeading = "No Favorite Terms To Show"
	let noFavoriteTermsSubheading = "There are no favorite terms in this category. When you choose some terms to be favorites, they will show here."

	
	
	// segues
	let segueFlashcardOptions = "segueFlashcardOptions"
	let segueSelectCategory = "segueSelectCategory"
	let segueAssignCategory = "segueAssignCategory"
	let segueCategory = "segueCategory"
	let segueValidationVC = "segueValidationVC"
	let segueTerm = "segueTerm"
	let segueSingleLineInput = "segueSingleLineInput"
	let segueMultiLineInput = "segueMultiLineInput"
	let segueLearningSet = "segueToLearningSet"
	let segueLearningOptions = "segueToLearningHomeOptions"
	
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
	
	// MARK: - Maximum lengths for fields
	let maxLengthTermName = 50
	let maxLengthTermDefinition = 100
	let maxLengthTermExample = 100
	let maxLengthMyNotes = 100
	let maxLengthCategoryName = 50
	let maxLengthCategoryDescription = 100
	
    let requeueInterval = 7 //interval to requeue a question in a learning set if it is answered wrong
}
