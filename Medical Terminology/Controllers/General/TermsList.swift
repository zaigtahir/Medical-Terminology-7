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
	
	private let tcTB = TermControllerTB()
	
	private var sectionNames = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	
	private var termIDsList = [[Int]] ()
	
	private var count: Int = 0 	// used to maintain the count of terms in the list
	
	/**
	If containsText = nil then will make an alphabetical list of the term names
	If containsText = some value, then will wake an alphabetial list of term names or the definition that contains that value
	*/
	
	func makeList (categoryIDs: [Int], showFavoritesOnly: Bool, containsText: String?) {
		
		// clear any current values from the termIDsList and count
		count = 0
		termIDsList = [[Int]] ()
		
		for s in sectionNames {
			
			let termIDs = tcTB.getTermIDs(categoryIDs: categoryIDs, showFavoritesOnly: showFavoritesOnly, nameStartsWith: s, nameContains: .none, containsText: containsText)
			
			
			termIDsList.append(termIDs)
			
			// adding to the list count
			count = count + termIDs.count
		}
	}
	
	func makeListForAssignTerms_AllTerms (nameContains: String?) {
		
		// clear any current values from the termIDsList and count
		count = 0
		termIDsList = [[Int]] ()
		
		for s in sectionNames {
			
			let termIDs = tcTB.getTermIDs_AssignTerms_AllTerms(nameStartsWith: s, nameContains: nameContains)
			
			termIDsList.append(termIDs)
			
			// adding to the list count
			count = count + termIDs.count
		}
		
	}
	
	func makeListForAssignTerms_AssignedOnly (assignedCategoryID: Int, nameContains: String?) {
		
		// clear any current values from the termIDsList and count
		count = 0
		termIDsList = [[Int]] ()
		
		for s in sectionNames {
			
			let termIDs = tcTB.getTermIDs_AssignTerms_AssignedOnly(assignedCategoryID: assignedCategoryID, nameStartsWith: s, nameContains: nameContains)
			
			termIDsList.append(termIDs)
			
			// adding to the list count
			count = count + termIDs.count
			print ("count: \(count)")
		}
		
	}
	
	func makeListForAssignTerms_UnassignedOnly (notAssignedCatetory: Int, nameContains: String?) {
		
		// clear any current values from the termIDsList and count
		count = 0
		termIDsList = [[Int]] ()
		
		for s in sectionNames {
			
			let termIDs = tcTB.getTermIDs_AssignTerms_UnassignedOnly(notAssignedCategoryID: notAssignedCatetory, nameStartsWith: s, nameContains: nameContains)
			
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
	
	func removeIndex (indexPath: IndexPath) {
		// if this indexPath exists, then remove it

		let ids = termIDsList[indexPath.section]
		
		if ids.count == 0 {
			return
		}
		
		if indexPath.row >= ids.count {
			return
		}
		
		if indexPath.row == ids.count - 1 {
			//requesting to remove the last item
			termIDsList[indexPath.section].removeLast()
		} else {
			termIDsList[indexPath.section].remove(at: indexPath.row)
		}
		
	}

}
