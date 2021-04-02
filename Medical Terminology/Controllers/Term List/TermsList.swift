//
//  TermsList.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/1/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

// a class to hold an list of termIDs in sections a-z

class TermsList {
	
	private let tc = TermController()
	
	private var sectionNames = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	
	private var termIDsList = [[Int]] ()
	
	/**
	If containsText = nil then will make an alphabetical list of the term names
	If containsText = some value, then will wake an alphabetial list of term names or the definition that contains that value
	*/
	
	func makeList (categoryID: Int, showFavoritesOnly: Bool?, containsText: String?) {
		
		// clear any current values from the termIDsList first
		termIDsList = [[Int]] ()
		
		for s in sectionNames {
			
			var isFavorite: Bool?
			if showFavoritesOnly == true {
				isFavorite = true
			}
			
			let termIDs = tc.searchTermIDs(categoryID: categoryID, isFavorite: isFavorite, nameStartsWith: s, nameContains: .none, containsText: containsText)
			
			termIDsList.append(termIDs)
		}
	}
	
	func getSectionNames () -> [String] {
		return sectionNames
	}
	
	func getSectionName (section: Int) -> String {
		return sectionNames[section]
	}
	
	func getRowCount (section: Int) -> Int {
		return termIDsList[section].count
	}
	
	func getTermID (indexPath: IndexPath) -> Int {
		return termIDsList[indexPath.section][indexPath.row]
	}
	
}
