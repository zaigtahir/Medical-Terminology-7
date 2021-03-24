//
//  TermController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/23/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

class TermController {
	
	func getTerm (termID: Int) -> Term {
		
		let query = "SELECT * FROM \(myConstants.dbTableTerms) WHERE termID = \(termID)"
		if let resultSet = myDB.executeQuery(query, withArgumentsIn: []) {
			resultSet.next()
			return makeTerm(resultSet: resultSet)
		} else {
			print("fatal error could not make result set or get term in getTerm")
			return Term()
		}
	}
	
	private func makeTerm (resultSet: FMResultSet) -> Term {
		
		let termID = Int(resultSet.int(forColumn: "termID"))
		var name = resultSet.string(forColumn: "name") ?? ""
		let definition = resultSet.string(forColumn: "definition")  ?? ""
		let example = resultSet.string(forColumn: "example")  ?? ""
		let secondCategoryID = Int(resultSet.int(forColumn: "secondCategoryID"))
		let audioFile = resultSet.string(forColumn: "audioFile")  ?? ""
		let f = Int(resultSet.int(forColumn: "isFavorite"))
		let m = Int(resultSet.int(forColumn: "isMyTerm"))
		
		let term = Term(termID: termID, name: name, definition: definition, example: example, secondCategoryID: secondCategoryID, audioFile: audioFile, isFavorite: f == 1, isMyTerm: m == 1)
		
		return term
	}
	
}
