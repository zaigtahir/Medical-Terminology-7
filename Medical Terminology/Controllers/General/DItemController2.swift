//
//  DItemController2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/12/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

class DItemController2 {
	
	func getDItems (whereQuery: String)  -> [DItem] {
		
		//return an array of DItems based on the whereClause
		//if nothing found return an empty array		
		//displayTerm will be selected instead of term for the item term if there is something in the displayTerm
		
		// MARK: Modified
		let query = "SELECT * FROM dictionary \(whereQuery)"
		
		var dItems = [DItem]()
		
		if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
			
			while resultSet.next() {
				
				let itemID = Int(resultSet.int(forColumn: "itemID"))
				var term = resultSet.string(forColumn: "term") ?? ""
				let termDisplay = resultSet.string(forColumn: "termDisplay") ?? ""
				let definition = resultSet.string(forColumn: "definition")  ?? ""
				let example = resultSet.string(forColumn: "example")  ?? ""
				let categoryID = Int(resultSet.int(forColumn: "categoryID"))
				let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
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
				
				let item = DItem(itemID: itemID,
								 term: term,
								 definition: definition,
								 example: example,
								 categoryID: categoryID,
								 audioFile: audioFile,
								 isFavorite: isFavorite,
								 learnedTerm: learnedTerm,
								 learnedDefinition: learnedDefinition,
								 answeredTerm: answeredTerm,
								 answeredDefinition: answeredDefintion)
				
				dItems.append(item)
			}
		}
		return dItems
	}
	
}
