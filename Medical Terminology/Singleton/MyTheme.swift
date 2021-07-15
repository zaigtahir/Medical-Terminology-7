//
//  SharedSettings.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/1/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class MyTheme{

	/*
	System gray 6	for card background set System Gray 6
	System gray 5	for disabled button background color
	System gray 2	for disabled button text tint
	*/

	
	let colorMain = UIColor(named: "color main")
	let colorMain2 = UIColor(named: "color main 2")
	let colorText = UIColor(named: "color text")
	
	// Button Colors
	let colorButtonDisabledBackground = (UIColor.systemGray5)
	let colorButtonEnabledBackground = (UIColor.secondaryLabel)
	// use for color of header icons, and image buttons
	let colorButtonDisabledTint = (UIColor.systemGray2)
	
	// use for row selectors that need to be disabled
	let colorButtonNoBackgroundDisabledTint = (UIColor.systemGray5)
	
	
	let colorButtonEnabledTint = UIColor(named: "color text button")
	let colorButtonText = UIColor(named: "color text button")
	
	let colorAddButton = UIColor(named: "color main")
	let colorSaveButton = UIColor(named: "color main")
	let colorButtonDelete = UIColor.systemPink
	
	// MARK: validation field colors
	let validFieldEntryColor = UIColor(named: "color text")
	let invalidFieldEntryColor = UIColor.systemPink
	
	//MARK: Table Colors
	let colorCellGray = UIColor.secondarySystemBackground	//use for tables with cells that should be grayish
	
	//MARK: favorite color
    let colorFavorite = UIColor(named: "color favorite")
	let colorNotFavorite = UIColor.secondaryLabel
    
    //MARK: Common colors: probably will need to remove
 	
    let colorCardBorder = UIColor(named: "color card border")
	
    let colorCorrect = UIColor(named: "color green")
    let colorIncorrect = UIColor(named: "color red")
	let colorDestructive = UIColor(named: "color red")
    
    //MARK: Flashcards
    let colorFlashcardHomeButton = UIColor(named: "color main")
    
    //MARK: Learning home
    let colorLhPbForeground = UIColor(named: "color main 2")
    let colorLhPbBackground = UIColor(named: "color pb background")
    //let colorLhPbFill = UIColor.systemBackground
	let colorLhPbFill = UIColor(named: "color main 2")
	
    //MARK: Learning set
    let colorLsNotAnswered = UIColor(named: "color main 2")
    
    //MARK: Test home
	
    //colors of test set home
    let colorTestPbForeground = UIColor(named: "color main")
    let colorTestPbBackground = UIColor(named: "color pb background")
	let colorTestPbFillcolor = UIColor(named: "color main")
    
    //MARK: Test set colors
    let colorQsNotAnswered = UIColor(named: "color main")
    	
	//MARK: Category List controller row swipe action colors
	let colorInfoButton = UIColor(named: "color main")
	let colorEditButton = UIColor(named: "color main")
	
	let colorSelectedRowIndicator = UIColor(named: "color main")
	
	let colorLockedCategory = UIColor.systemGray4
	
	// MARK: category home progress bars
	let colorProgressPbForeground = UIColor(named: "color green")
	let colorProgressPbBackground = UIColor.systemBackground
	let colorProgressPbFillcolor = UIColor.systemGray5
	
	// MARK: row selector images
	
	let imageCircle = UIImage.init(systemName: "circle")
	let imageCircleFill = UIImage.init(systemName: "circle.fill")
	let imageSquare = UIImage.init(systemName: "square")
	let imageSquareFill = UIImage.init(systemName: "square.fill")
	
    // MARK: images
    let imageCorrect = UIImage.init(systemName: "checkmark.circle.fill")
    let imageIncorrect = UIImage.init(systemName: "xmark.circle.fill")
    
	// MARK: view controller header images, show on top when adding
	let imageHeaderAdd = UIImage.init(systemName: "wand.and.stars")
	
	let imageDone = UIImage.init(systemName: "star.fill")
	let imageInfo = UIImage.init(systemName: "info.circle")
    
	//use next three speaker images to make animation
	let imageSpeaker = UIImage.init(systemName: "play.circle.fill")
    let imageSpeakerPlaying = UIImage.init(systemName: "pause.circle.fill")

    //progress bar width
    let progressBarWidth = CGFloat(integerLiteral: 15)

}
