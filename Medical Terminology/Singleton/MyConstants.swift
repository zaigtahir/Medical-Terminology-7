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
    
    // app and website information
    let appWebsite = "https://www.theappgalaxy.com/prefixesandsuffixes.html"
    let companyWebsite = "https://theappgalaxy.com"
    let copyrightNotice = "Copyright: 2021 by Dr. Tahir"
    let appEmail = "support@theappgalaxy.com"
    let appTitle = "Practical Medical Terminology"
    
    let noFavoritesAvailableText = "There are no favorites available to show"
    
    //question feedback remarks
    let feedbackNotAnswered = "Select An Answer"
    let feedbackAnsweredCorrect = ["Yes! You got it!", "Correct! Great job!", "You are right!", "Awesome! You're right!"]
    let feedbackAnsweredWrong = ["Incorrect"]
    
    //do not change these numbers. They are used as indexes of arrays too
    let listType_Full = 0
    let listType_Favorite = 1
    let listType_Random = 2
    let listType_Sample = 3
    
    let button_cornerRadius = CGFloat(integerLiteral: 5)
    let layout_cornerRadius = CGFloat(integerLiteral: 10)
    let layout_sideMargin = CGFloat(integerLiteral: 20)
    let layout_topBottomMargin = CGFloat(integerLiteral: 10)
    
    let segue_catetories = "segue_categories"
    
    let requeueInterval = 7 //interval to requeue a question in a learning set if it is answered wrong
}
