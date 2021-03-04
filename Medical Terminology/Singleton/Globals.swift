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

//this AppPurchaseStatus has string type as I will be saving this value in the UserDefaults

enum AppPurchaseStatus: String {
    case newInstall = "newInstall"
    case freeTrial = "freeTrialPeriod"
    case expiredTrial = "expiredTrial"
    case fullVersion = "fullVersion"

}
