//
//  AlphaListController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 11/20/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//


import Foundation
import SQLite3

//manage the full and favorite alphabetical lists and act as a datasource to fill the tables

class AlphaListController2 {
    
    private var dIC = DItemController ()
    private var listToShow = myConstants.listType_Full
    private var fullAlphaList : AlphaList!
    private var favoritesAlphaList : AlphaList!
    
    init () {

        //initialize both lists
        fullAlphaList = makeAlphaList(favoritesOnly: false)
        favoritesAlphaList = makeAlphaList(favoritesOnly: true)
        
    }
    
    func setListToShow (listToShow: Int) {
        self.listToShow = listToShow
        
        //if the list to show is favorites, need to reload it from the database
        if listToShow == myConstants.listType_Favorite {
            favoritesAlphaList = makeAlphaList(favoritesOnly: true)
        }
    }
    
    func getListToShow () -> Int {
        return listToShow
       
    }
    
    func getTitleForHeader (sectionIndex: Int) -> String {
        if listToShow == myConstants.listType_Full {
            return fullAlphaList.sections[sectionIndex]
        } else {
            return favoritesAlphaList.sections[sectionIndex]
        }
    }
    
    func getDItem (indexPath: IndexPath) -> DItem {
        if listToShow == myConstants.listType_Full {
            return fullAlphaList.listItems[indexPath.section][indexPath.row]
        } else {
            return favoritesAlphaList.listItems[indexPath.section][indexPath.row]
        }
    }
    
    func getNumberOfRowsInSection (section: Int) -> Int {
        if listToShow == myConstants.listType_Full {
            return fullAlphaList.listItems[section].count
        } else {
            return favoritesAlphaList.listItems[section].count
        }
    }
    
    func getNumberOfSections () -> Int {
        if listToShow == myConstants.listType_Full {
            return fullAlphaList.sections.count
        } else {
            return favoritesAlphaList.sections.count
        }
    }
    
    func getSectionIndexTitles () -> [String] {
        if listToShow == myConstants.listType_Full {
            return fullAlphaList.sections
        } else {
            return favoritesAlphaList.sections
        }
    }
    
    func remakeFavoritesList() {
       favoritesAlphaList = makeAlphaList(favoritesOnly: true)
    }
    
    private func makeAlphaList (favoritesOnly: Bool) -> AlphaList {
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
            
            var query: String
            
            if favoritesOnly {
                query = "term LIKE '\(myChar)%' and isFavorite <> 0 ORDER BY term"
            } else {
                query = "term LIKE '\(myChar)%' ORDER BY term"
            }
            
            let listItems = dIC.getDItems(whereQuery: query)
            
            if listItems.count > 0 {
                alphaList.listItems.append(listItems)
                alphaList.sections.append(sString)
            }
            
        }
        return alphaList
    }
    
    
}

