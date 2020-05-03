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
    
    //website names
    let appWebsite = "https://theappgalaxy.com"
    
    //do not change these numbers. They are used as indexes of arrays too
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
