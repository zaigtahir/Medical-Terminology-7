//
//  Theme.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/6/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class Theme_bk {
    
    //will hold theme colors and variables
    
    var color_background: UIColor
    var color_card_background : UIColor
    var color_card_done_background: UIColor
    
    var color_heading: UIColor
    var color_subheading_1: UIColor
    var color_subheading_2 : UIColor
    
    var color_disabled : UIColor
    
    var color_favorite_button_tintColor : UIColor
    var color_favorite_button_onTintColor : UIColor

    var color_heart_red : UIColor
    var color_correctAnswer : UIColor
    var color_wrongAnswer : UIColor
    var color_quizStatusDone : UIColor
    
    var image_isFavoriteImage : UIImage
    var image_isNotFavoriteImage : UIImage
    var image_favoriteListActive : UIImage
    var image_favoriteList : UIImage
    
    var image_notLearned: UIImage
    var image_learned: UIImage
    
    var image_check : UIImage
    var image_cross : UIImage
    
    var image_arrow_up : UIImage
    var image_arrow_down : UIImage
    var image_arrow_right : UIImage
    var image_arrow_left : UIImage
    
    var font_unanswered : UIFont
    var font_selectedAndCorrect : UIFont
    var font_selectedAndNotCorrect : UIFont
    var font_notSelectedAndCorrect : UIFont
    var font_notSelectedAndNotCorrect : UIFont
    
    
    init() {
        color_background = UIColor (red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        color_card_background = UIColor (red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        color_card_done_background = UIColor (red: 150/255, green: 20/255, blue: 10/255, alpha: 1)
        
        color_heading = UIColor (red: 204/255, green: 204/255, blue: 0/255, alpha: 1)
        color_subheading_1 = UIColor (red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        color_subheading_2 = UIColor (red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
        color_disabled = UIColor (red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
        
        color_favorite_button_tintColor = UIColor.red
        color_favorite_button_onTintColor = UIColor.blue
        
        color_heart_red = UIColor(red: 244/255, green: 44/255, blue: 115/255, alpha: 1 )
        color_correctAnswer = UIColor (red: 144/255, green: 169/255, blue: 86/255, alpha: 1)
        color_wrongAnswer = UIColor(red: 244/255, green: 95/255, blue: 66/255, alpha: 1)
        color_quizStatusDone = UIColor (red: 144/255, green: 169/255, blue: 86/255, alpha: 1)
        
        image_isFavoriteImage = UIImage (named: "heart redish")!
        image_isNotFavoriteImage = UIImage (named: "heart gray")!
        image_favoriteListActive = UIImage (named: "double heart redish")!
        image_favoriteList = UIImage(named: "double heart gray")!
        
        image_notLearned = UIImage(named: "check_gray")!
        image_learned = UIImage(named: "check_green")!
        
        image_check = UIImage (named: "check_green")!
        image_cross = UIImage (named: "cross_red")!
        
        image_arrow_up = UIImage (named: "arrow_up")!
        image_arrow_down = UIImage (named: "arrow_down")!
        image_arrow_right = UIImage (named: "arrow_right")!
        image_arrow_left = UIImage (named: "arrow_left")!
        
        font_unanswered = UIFont(name:"HelveticaNeue", size: 15.0)!
        font_selectedAndCorrect = UIFont(name:"HelveticaNeue-Bold", size: 15.0)!
        font_selectedAndNotCorrect = UIFont(name:"HelveticaNeue-Bold", size: 15.0)!
        font_notSelectedAndCorrect = UIFont(name:"HelveticaNeue-Bold", size: 15.0)!
        font_notSelectedAndNotCorrect = UIFont(name:"HelveticaNeue", size: 15.0)!
    }
}
