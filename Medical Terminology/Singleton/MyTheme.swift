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
    
    //colors
    let colorFavorite = UIColor(named: "color favorite")
    let colorNotFavorite = UIColor(named: "color inactive icon")
    
    //MARK: Common colors
    let colorButtonEnabledTint = UIColor(named: "color text button")
    let colorButtonDisabled = UIColor(named: "color button disabled")
    let colorButtonDisabledTint = UIColor(named: "color inactive icon")
    let colorCardBorder = UIColor(named: "color card border")
	
    let colorCorrect = UIColor(named: "color correct")
    let colorIncorrect = UIColor(named: "color incorrect")
    
    //MARK: Flashcards
    let color_fch_button = UIColor(named: "color main")
    
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
    
    //MARK: Table Colors
    let colorSectionHeader = UIColor(named: "color main")
    let colorSectionText = UIColor(named: "color text")
	let colorCellGray = UIColor.secondarySystemBackground	//use for tables with cells that should be grayish
	
	//MARK: Category controller colors
	let colorInfoButton = UIColor(named: "color main")
	let colorEditButton = UIColor(named: "color main")
	
	let colorSelectedRowIndicator = UIColor(named: "color main")
	let colorUnselectedRowIndecator = UIColor(named: "color text")
	
	let imageSelectedRow = UIImage.init(systemName: "circle.fill")
	let imageUnselectedRow = UIImage.init(systemName: "circle")
	
    //MARK: images
    let imageCorrect = UIImage(named: "check circle filled")
    let imageIncorrect = UIImage(named: "cross circle filled")
    
    //use next three speaker images to make animation
    let imageSpeaker = UIImage(named: "speakerC")
    let imageSpeakerPlaying = UIImage(named: "speakerC_playing")

    //progress bar width
    let progressBarWidth = CGFloat(integerLiteral: 15)

}
