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
	let colorButtonDisabledTint = (UIColor.systemGray2)
	let colorButtonEnabledTint = UIColor(named: "color text button")

	//let colorBackground = UIColor.systemBackground
	
	//MARK: Table Colors
	let colorCellGray = UIColor.secondarySystemBackground	//use for tables with cells that should be grayish
	
	//MARK: favorite color
    let colorFavorite = UIColor(named: "color favorite")
	let colorNotFavorite = UIColor.secondaryLabel
    
    //MARK: Common colors: probably will need to remove
 	
    let colorCardBorder = UIColor(named: "color card border")
	
    let colorCorrect = UIColor(named: "color correct")
    let colorIncorrect = UIColor(named: "color incorrect")
    
    //MARK: Flashcards
    let colorFlashcardHomeButton = UIColor(named: "color main")
    
    //MARK: Learning home
    let colorLhPbForeground = UIColor(named: "color main 2")
    let colorLhPbBackground = UIColor(named: "color pb background")
    let colorLhPbFill = UIColor(named: "color main 2")
    
    let colorLhButton = UIColor(named: "color main")
    
    //MARK: Learning set
    let colorLsNotAnswered = UIColor(named: "color main 2")
    
    //MARK: Quiz home
    let colorQuizButton = UIColor(named: "color main")
    
    //colors of quiz set home
    let colorPbQuizForeground = UIColor(named: "color main")
    let colorPbQuizBackground = UIColor(named: "color pb background")
    let colorPbQuizFillcolor = UIColor(named: "color main")
    
    //MARK: Quiz set colors
    let colorQsNotAnswered = UIColor(named: "color main")
    
	//MARK: Category controller colors
	let colorInfoButton = UIColor(named: "color main")
	let colorEditButton = UIColor(named: "color main")
	
	let colorSelectedRowIndicator = UIColor(named: "color main")
	let colorUnselectedRowIndecator = UIColor(named: "color text")
	
	let colorUnavailableCatetory = UIColor.systemGray4
	
	let imageSelectCatetory =  UIImage.init(systemName: "square.stack.3d.up.fill")
	let imageAssignCategory = UIImage.init(systemName: "slider.horizontal.3")
	
	
	//MARK: row selector images
	let imageRowSelected = UIImage.init(systemName: "circle.fill")
	let imageRowNotSelected = UIImage.init(systemName: "circle")
	let imageRowCurrentCategoryNotSelected = UIImage.init(systemName: "circle.circle")
	
    //MARK: images
    let imageCorrect = UIImage(named: "check circle filled")
    let imageIncorrect = UIImage(named: "cross circle filled")
    
    //use next three speaker images to make animation
	let imageSpeaker = UIImage.init(systemName: "speaker.fill")
    let imageSpeakerPlaying = UIImage(systemName: "speaker.wave.2.fill")

    //progress bar width
    let progressBarWidth = CGFloat(integerLiteral: 15)

	
	func formatButtonColor (button: UIButton, enabledColor: UIColor) {
		
		if button.isEnabled {
			button.backgroundColor = enabledColor
			button.tintColor = colorButtonEnabledTint
			button.setTitleColor(colorButtonEnabledTint, for: .normal)
			
		} else {
			button.backgroundColor = colorButtonDisabledBackground
			button.tintColor = colorButtonDisabledTint
			button.setTitleColor(UIColor.systemBackground, for: .disabled)
		}
		
	}
}
