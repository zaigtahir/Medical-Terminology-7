//
//  SearchLists.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/8/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation

class SearchLists {
    
    let dIC = DItemController ()
 
    func makeAlphaList (favoritesOnly: Bool) -> AlphaList {
        //will return an AlphaList object
        //base on if favorite or not
        //match or not
        
        //unicode a = 97
        //unicode A = 65
        
        let alphaList = AlphaList()
        
        for i in 0...25 {
            let myNum = UnicodeScalar(i+97)
            let myChar = Character(myNum!)
            
            let sName = UnicodeScalar(i + 65)
            let sString = String(Character(sName!))
            
            var query = String()
            
            if favoritesOnly {
                query = "WHERE term LIKE '\(myChar)%' and isFavorite <> 0 ORDER BY term"
            } else {
                query = "WHERE term LIKE '\(myChar)%' ORDER BY term"
            }
            
            let listItems = dIC.getDItems(whereQuery: query)
            
            if listItems.count > 0 {
                alphaList.listItems.append(listItems)
                alphaList.sections.append(sString)
                }
        }
        return alphaList
    }
    
    func makeSearchList (favoritesOnly: Bool, searchText: String) -> [DItem] {
        
        var query = String()
        
        //TODO: how will using dash first work? "-" for search
        
        if favoritesOnly {
            query = "WHERE term LIKE '%\(searchText)%' and isFavorite <> 0 ORDER BY term"
        } else {
            query = "WHERE term LIKE '%\(searchText)%' ORDER BY term"
        }
        
        let dItems = dIC.getDItems(whereQuery: query)
        
        return dItems
    }
    
}
