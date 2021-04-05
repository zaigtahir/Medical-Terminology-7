//
//  TermsList.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/1/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

/**
My class to hold an list of termIDs in sections a-z
The list should be such that the termIDs are unique to that my implementation of firstOccuranceOf will work
*/
class TermsList {
	
	private let tc = TermController()
	
	private var sectionNames = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	
	private var termIDsList = [[Int]] ()
	
	private var count: Int = 0 	// used to maintain the count of terms in the list
	
	/**
	If containsText = nil then will make an alphabetical list of the term names
	If containsText = some value, then will wake an alphabetial list of term names or the definition that contains that value
	*/
	
	func makeList (categoryID: Int, showFavoritesOnly: Bool?, containsText: String?) {
		
		// clear any current values from the termIDsList and count
		count = 0
		termIDsList = [[Int]] ()
		
		for s in sectionNames {
			
			var isFavorite: Bool?
			if showFavoritesOnly == true {
				isFavorite = true
			}
			
			let termIDs = tc.searchTermIDs(categoryID: categoryID, isFavorite: isFavorite, nameStartsWith: s, nameContains: .none, containsText: containsText)
			
			termIDsList.append(termIDs)
			
			// adding to the list count
			count = count + termIDs.count
		}
	}
	
	func getSectionNames () -> [String] {
		return sectionNames
	}
	
	func getCount () -> Int {
		return count
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
	
	/**
	Returns the index path of the first matching termID. As this list is supposed to be unique, this will be considered to be the only possible matching value
	*/
	func findIndexOf (termID: Int) -> IndexPath? {
		for i in 0...sectionNames.count - 1 {
			if let row = termIDsList[i].firstIndex(of: termID) {
				
				return IndexPath(row: row, section: i)
			}
		}
		return nil
	}

}
