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
    
    //for light theme, use color gray back for card, tab bar, disabled button color
    
    //colors
    let colorFavorite = UIColor(named: "color favorite")
    let colorNotFavorite = UIColor(named: "color inactive icon")
    let colorMain = UIColor(named: "color blue 4")  //to remove later
    
    //MARK: Common colors
    let colorButtonEnabledTint = UIColor(named: "color text button")
    let colorButtonDisabled = UIColor(named: "color button disabled")
    let colorButtonDisabledTint = UIColor(named: "color inactive icon")
    
    //MARK: Flashcards
    let color_fch_button = UIColor(named: "color main")
        
    //MARK: Learning home
    let colorLhPbForeground = UIColor(named: "color main")
    let colorLhPbBackground = UIColor(named: "color pb background")
    let colorLhPbFill = UIColor(named: "color background")
    
    let colorLhButton = UIColor(named: "color main")
    
    //MARK: Quiz home
    let colorQuizButton = UIColor(named: "color main 2")

    let color_correct = UIColor(named: "color correct")
    let color_incorrect = UIColor(named: "color incorrect")
    let color_learned = UIColor(named: "color correct")
    let color_notlearned = UIColor(named: "color card border")
    
    let colorCardBorder = UIColor(named: "color card border")
    

    //colors of quiz set home
    let color_pb_quiz_foreground = UIColor(named: "color main 2")
    let color_pb_quiz_background = UIColor(named: "color pb background")
    let color_pb_quiz_fillcolor = UIColor(named: "color background")
    
    
    //MARK: List controller
    let color_searchText = UIColor(named: "color text")
    let color_section_header = UIColor(named: "color main")
    let color_section_text = UIColor(named: "color text")
    
    let color_correctAnswer = UIColor (red: 144/255, green: 169/255, blue: 86/255, alpha: 1)
    let color_wrongAnswer = UIColor(red: 244/255, green: 95/255, blue: 66/255, alpha: 1)
    let color_quizStatusDone = UIColor (red: 144/255, green: 169/255, blue: 86/255, alpha: 1)
    
    
    //images
    let image_correct = UIImage(named: "check circle filled")
    let image_incorrect = UIImage(named: "cross circle filled")
    
    let image_speaker_playing = UIImage(named: "speaker_playing")
    let image_speaker_not_playing = UIImage(named: "speaker_not_playing")
    
    let font_unanswered = UIFont(name:"HelveticaNeue", size: 15.0)
    let font_selectedAndCorrect = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
    let font_selectedAndNotCorrect = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
    let font_notSelectedAndCorrect = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
    let font_notSelectedAndNotCorrect = UIFont(name:"HelveticaNeue", size: 15.0)
    
    //progress bar width
    let progressBarWidth = CGFloat(integerLiteral: 15)
    
    
}
