//
//  DItemController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 11/3/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3
import AVFoundation

/**
 
 fields:
 itemID
 term
 definition
 example
 category
 audioFile
 isFavorite
 learnedTerm
 learnedDefinition
 answeredTerm: 0 = not answered, 1 = WRONG, 2 = CORRECT
 answeredDefinition: 0 = not answered, 1 = WRONG, 2 = CORRECT
 orderBy: 1 = term, 2 = random
 
 */

class DItemController {
    /**
     pass it a query that will lead to generating a count
     example: SELECT COUNT(*) WHERE itemID > 1
     */
    func getCount (query: String) -> Int {
        
        if let resultSet = myFMDB.fmdb.executeQuery(query, withParameterDictionary: nil) {
            
            resultSet.next()
            
            return Int(resultSet.int(forColumnIndex: 0))
            
        } else {
            print("Some problem getting favoite count in ditem controller getFavoritesCount")
            
            return 0
        }
    }
    
    func getDItems (whereQuery: String)  -> [DItem] {
        
        //return an array of DItems based on the whereClause
        //if nothing found return an empty array
        
        //null strings in database will become an empty string in the string variables here
        
        //displayTerm will be selected instead of term for the item term if there is something in the displayTerm
        
        let selectPortion = "SELECT itemID, term, termDisplay, definition, ifnull(example, '') AS example, category, ifnull(audioFile, '') AS audioFile, isFavorite, learnedTerm, learnedDefinition, answeredTerm, answeredDefinition FROM dictionary "
        
        let query = "\(selectPortion) \(whereQuery)"
        
        var dItems = [DItem]()
        
        if let resultSet = myFMDB.fmdb.executeQuery(query, withParameterDictionary: nil) {
            
            while resultSet.next() {
                
                let itemID = Int(resultSet.int(forColumn: "itemID"))
                var term = resultSet.string(forColumn: "term") ?? "none found"
                let termDisplay = resultSet.string(forColumn: "termDisplay") ?? ""
                let definition = resultSet.string(forColumn: "definition")  ?? ""
                let example = resultSet.string(forColumn: "example")  ?? ""
                let category = Int(resultSet.int(forColumn: "category"))
                let audioFile = resultSet.string(forColumn: "audioFile")  ?? "none found"
                let f = Int(resultSet.int(forColumn: "isFavorite"))
                let t = Int(resultSet.int(forColumn: "learnedTerm"))
                let d = Int(resultSet.int(forColumn: "learnedDefinition"))
                let answeredTerm = Int(resultSet.int(forColumn: "answeredTerm"))
                let answeredDefintion = Int(resultSet.int(forColumn: "answeredDefinition"))
                
                var isFavorite: Bool = false
                var learnedTerm: Bool = false
                var learnedDefinition: Bool = false
                
                if f != 0 {
                    isFavorite = true
                }
                
                if t != 0 {
                    learnedTerm = true
                }
                
                if d != 0 {
                    learnedDefinition = true
                }
                
                //replace term with termDisplay if there is something in term display
                if termDisplay.isEmpty == false {
                    term = termDisplay
                }
                
                let item = DItem(itemID: itemID, term: term, definition: definition, example: example, category: category, audioFile: audioFile, isFavorite: isFavorite, learnedTerm: learnedTerm, learnedDefinition: learnedDefinition, answeredTerm: answeredTerm, answeredDefinition: answeredDefintion)
                
                dItems.append(item)
            }
            
        }
        
        return dItems
    }
    
    func getDItem (itemID: Int) -> DItem {
        
        let query = " WHERE itemID = \(itemID) "
        
        let dItems = getDItems(whereQuery: query)
        
        if dItems.count == 0 {
            
            print("DItemController: getDItem: ERROR!!! could not find dItem with itemID: \(itemID). Returning a default dItem")
            
            return DItem()
            
        } else {
            
            return dItems[0]
        }
    }
    
    //MARK: learning related functions
    
    /**
     will make a WHERE clause based on the inputs (starts with WHERE)
     example: WHERE itemID = 56
     -1 will ignore the value
     *values*
     'learnedState' 0 = one or both components not learned, 1 = both components are learned
     'orderBy" 1 = term 2 = random
     */
    
    func wherePortion (favoriteState: Int, learnedState: Int, orderBy: Int, limit: Int) -> String {
        
        var query = " WHERE itemID >= 0 "
        
        if favoriteState != -1 {
            
            query.append(" AND isFavorite = \(favoriteState) ")
        }
        
        switch learnedState {
            
        case 0:
            query.append(" AND (learnedTerm = 0  OR learnedDefinition = 0) ")
            
        case 1:
            query.append(" AND (learnedTerm = 1 AND learnedDefinition = 1) ")
            
        default:
            query.append(" ")
        }
        
        switch orderBy {
            
        case 1:
            query.append(" ORDER BY term ")
            
        case 2:
            query.append(" ORDER BY RANDOM() ")
            
        default:
            query.append("")
            
        }
        
        if limit != -1 {
            query.append(" LIMIT \(limit)")
        }
        
        return query
        
    }
    
    func getCount ( favoriteState: Int) -> Int {
        
        let wQuery = wherePortion(favoriteState: favoriteState, learnedState: -1, orderBy: -1, limit: -1)
        
        let fullQuery = "SELECT COUNT (*) FROM dictionary \(wQuery)"
        
        return getCount(query: fullQuery)
        
    }
    
    func getCount ( favoriteState: Int, learnedState: Int ) -> Int {
        
        let wQuery = wherePortion(favoriteState: favoriteState, learnedState: learnedState, orderBy: -1, limit: -1)
        
        let fullQuery = "SELECT COUNT (*) FROM dictionary \(wQuery)"
        
        return getCount(query: fullQuery)
        
    }
    
    func getItemIDs ( favoriteState: Int, learnedState: Int, orderBy: Int = -1, limit: Int = -1 ) -> [Int] {
        
        var itemIDs = [Int]()
        
        let wQuery = wherePortion(favoriteState: favoriteState, learnedState: learnedState, orderBy: orderBy, limit: limit)
        
        let fullQuery = "SELECT itemID FROM dictionary \(wQuery)"
        
        if let resultSet = myFMDB.fmdb.executeQuery(fullQuery, withParameterDictionary: nil) {
            
            while resultSet.next() {
                
                itemIDs.append(Int(resultSet.int(forColumn: "itemID")))
            }
            
        }
        
        return itemIDs
    }

    func clearLearnedItems (favoriteState: Int) {
        
        switch favoriteState {
            
        case 0:
            //clear not favorites only
            myFMDB.fmdb.executeUpdate("UPDATE dictionary SET learnedTerm = ?, learnedDefinition = ? WHERE isFavorite = 0", withArgumentsIn: [0,0])
        case 1:
            //clear favorites only
            myFMDB.fmdb.executeUpdate("UPDATE dictionary SET learnedTerm = ?, learnedDefinition = ? WHERE isFavorite = 1", withArgumentsIn: [0,0])
        
        default:
            //clear both
            myFMDB.fmdb.executeUpdate("UPDATE dictionary SET learnedTerm = ?, learnedDefinition = ? WHERE itemID >= 0", withArgumentsIn: [0,0])
        }

    }
    
    func clearLearnedItems (itemIDs: [Int]) {
        
        for itemID in itemIDs
        {
            let query = "UPDATE dictionary SET learnedTerm = ?, learnedDefinition = ? WHERE itemID = ?"
            
            myFMDB.fmdb.executeUpdate(query, withArgumentsIn: [0, 0, itemID])
        }
        
    }
    
    func saveFavorite (itemID: Int, isFavorite: Bool) {
        
        var favoriteState = 0
        if isFavorite {
            favoriteState = 1
        }
        
        myFMDB.fmdb.executeUpdate("UPDATE dictionary SET isFavorite = ? where itemID = ?", withArgumentsIn: [favoriteState, itemID])
        
    }
    
    func toggleFavorite (itemID: Int) {
        let item = getDItem(itemID: itemID)
        saveFavorite(itemID: itemID, isFavorite: !item.isFavorite)
    }
    
    func saveLearnedTerm (itemID: Int, learnedState: Bool) {
        
        var state = 0
        if learnedState {
            
            state  = 1
        }
        
        myFMDB.fmdb.executeUpdate("UPDATE dictionary SET learnedTerm = ? where itemID  = ?", withArgumentsIn: [state, itemID])
    }
    
    func saveLearnedDefinition (itemID: Int, learnedState: Bool) {
        
        var state = 0
        
        if learnedState {
            state  = 1
        }
        
        myFMDB.fmdb.executeUpdate("UPDATE dictionary SET learnedDefinition = ? where itemID  = ?", withArgumentsIn: [state, itemID])
    }
    
    //MARK: QUIZ QUESTION related functions
    
    func clearAnsweredItems (isFavorite: Bool, questionsType: QuestionsType) {
        var query: String
        
        switch questionsType {
        case .random:
            if isFavorite {
                query = "UPDATE dictionary SET answeredTerm = 0, answeredDefinition = 0 WHERE (isFavorite = 1 AND itemID > 0)"
            } else {
                query = "UPDATE dictionary SET answeredTerm = 0, answeredDefinition = 0 WHERE itemID >= 0"
            }
            
        case .term:
            if isFavorite {
                query = "UPDATE dictionary SET answeredTerm = 0 WHERE (isFavorite = 1 AND itemID > 0)"
            } else {
                query = "UPDATE dictionary SET answeredTerm = 0 WHERE itemID >= 0"
            }
            
        default:
            if isFavorite {
                query = "UPDATE dictionary SET answeredDefinition = 0 WHERE (isFavorite = 1 AND itemID > 0)"
            } else {
                query = "UPDATE dictionary SET answeredDefinition = 0 WHERE itemID >= 0"
            }
        }
 
        myFMDB.fmdb.executeUpdate(query, withArgumentsIn: []  )
    }

    func clearAnsweredItems (itemIDs: [Int]) {
        
        for itemID in itemIDs {
            
            let query = "UPDATE dictionary SET answeredTerm = ?, answeredDefinition = ? WHERE itemID = ?"
            
            myFMDB.fmdb.executeUpdate(query, withArgumentsIn: [0, 0, itemID])
        }
        
    }
    
    func saveAnsweredTerm (itemID: Int, answerState: Int) {
        
        myFMDB.fmdb.executeUpdate("UPDATE dictionary SET answeredTerm = ? where itemID = ?", withArgumentsIn: [answerState, itemID])
    }
    
    func saveAnsweredDefinition (itemID: Int, answerState: Int) {
        
        myFMDB.fmdb.executeUpdate("UPDATE dictionary SET answeredDefinition = ? where itemID = ?", withArgumentsIn: [answerState, itemID])
    }
    
    func getTermsAnsweredCorrectlyCount (favoriteState: Int) -> Int {
        
        var query: String
    
        if favoriteState == -1 {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredTerm = 2"
            
        } else {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredTerm = 2 AND isFavorite = \(favoriteState)"
        }
        
        
        return getCount(query: query)
        
    }
    
    func getTermsAvailableCount (favoriteState: Int) -> Int {
        
        var query: String
        
        if favoriteState == -1 {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredTerm != 2"
            
        } else {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredTerm != 2 AND isFavorite = \(favoriteState)"
        }
        
        
        return getCount(query: query)
        
    }
    
    func getDefinitionsAnsweredCorrectly (favoriteState: Int) -> Int {
        
        var query: String
        
        if favoriteState == -1 {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredDefinition = 2"
            
        } else {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredDefinition = 2 AND isFavorite = \(favoriteState)"
        }
        
        
        return getCount(query: query)
        
    }
    
    func getDefinitionsAvailableCount (favoriteState: Int) -> Int {
        
        var query: String
        
        if favoriteState == -1 {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredDefinition != 2"
            
        } else {
            
            query =  "SELECT COUNT (*) FROM dictionary WHERE answeredDefinition != 2 AND isFavorite = \(favoriteState)"
        }
        
        
        return getCount(query: query)
        
    }

}

