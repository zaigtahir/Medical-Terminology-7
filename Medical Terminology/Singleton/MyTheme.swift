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
    let color_notAnswered = UIColor(named: "color card border")
    
    //MARK: Flashcards
    let color_fch_button = UIColor(named: "color main")
    
    //MARK: Learning home
    let colorLhPbForeground = UIColor(named: "color main 2")
    let colorLhPbBackground = UIColor(named: "color pb background")
    let colorLhPbFill = UIColor(named: "color main 2")
    
    let colorLhButton = UIColor(named: "color main")
    
    //MARK: Learning set
    
    let color_incorrect = UIColor(named: "color incorrect")
    let color_learned = UIColor(named: "color correct")
    
    //MARK: Quiz home
    let colorQuizButton = UIColor(named: "color main")
    let color_correct = UIColor(named: "color correct")
    
    //colors of quiz set home
    let color_pb_quiz_foreground = UIColor(named: "color main")
    let color_pb_quiz_background = UIColor(named: "color pb background")
    let color_pb_quiz_fillcolor = UIColor(named: "color background")
    
    
    //MARK: List controller
    let color_searchText = UIColor(named: "color text")
    let color_section_header = UIColor(named: "color main")
    let color_section_text = UIColor(named: "color text")
    
    let color_correctAnswer = UIColor (red: 144/255, green: 169/255, blue: 86/255, alpha: 1)
    let color_wrongAnswer = UIColor(red: 244/255, green: 95/255, blue: 66/255, alpha: 1)
    let color_quizStatusDone = UIColor (red: 144/255, green: 169/255, blue: 86/255, alpha: 1)
    
    //MARK: images
    let image_correct = UIImage(named: "check circle filled")
    let image_incorrect = UIImage(named: "cross circle filled")
    
    //use next three speaker images to make animation
    let image_speaker = UIImage(named: "speakerC")
    let image_speaker_playing = UIImage(named: "speakerC_playing")
    
    //progress bar width
    let progressBarWidth = CGFloat(integerLiteral: 15)
    
    
    
}
