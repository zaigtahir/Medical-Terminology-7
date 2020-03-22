//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class FlashCardVCH: NSObject {
    
    private var favoriteMode = false
    var viewMode : FlashCardViewMode = .both
    

    var listFull: [Int]
    var listFavorite: [Int]
    
    let dIC  = DItemController()
    
    override init() {
        listFull  = dIC.getItemIDs(favoriteState: -1, learnedState: -1)
        listFavorite  = dIC.getItemIDs(favoriteState: 1, learnedState: -1)
    }
    
    func setFavoriteMode (isFavoriteMode: Bool) {
        if isFavoriteMode {
            self.favoriteMode = true
            listFavorite = dIC.getItemIDs(favoriteState: 1, learnedState: -1)
        } else {
            self.favoriteMode = false
        }
    }
    
    func getFavoriteMode () -> Bool {
        return favoriteMode
    }
    
}
