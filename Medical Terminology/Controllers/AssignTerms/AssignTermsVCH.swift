//
//  AssignTermsVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/4/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol AssignTermsVCHDelegate: AnyObject {
	//func shouldUpdateDisplay()		// update state of other controls on the flashcard home screen
	//func reloadTableView()	// reload all the data
	
	func shouldReloadTable()
	func shouldUpdateDisplay()
	func shouldRemoveRowAt (indexPath: IndexPath)
	func shouldClearSearchText()
}


class AssignTermsVCH: NSObject, UITableViewDataSource, UITableViewDelegate

{
	
	var categoryID : Int!
	var searchText : String?
	
	/**
	0 = assigned
	1 = not assigned
	*/
	var assignedListViewMode = 0
	var termsList = TermsList()
	
	weak var delegate : AssignTermsVCHDelegate?
	
	// controllers
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let tu = TextUtilities()
	private let utilities = Utilities()
	
	override init() {
		super.init()
	}
	
	func setupCategoryID (categoryID: Int) {
		self.categoryID = categoryID
	
		updateData()
	}
	
	// MARK: - Update data function
	
	/**
	Will update the internal termsList
	*/
	func updateData () {
		
		
		// MARK: add code to remove more than 1 space also?
		// Clean up the search text
		
		var cleanText : String?
		
		if let nonCleanText = searchText {
			// there is search text
			cleanText = tu.removeLeadingTrailingSpaces(string: nonCleanText)
		}
		
		switch assignedListViewMode {

		case 0:
			termsList.makeListForAssignTerms_AssignedOnly(assignedCategoryID: categoryID, nameContains: cleanText)
		default:
			termsList.makeListForAssignTerms_UnassignedOnly(notAssignedCatetory: categoryID, nameContains: cleanText)
			
		}
	
	}
	
	
	// MARK: - Table functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if termsList.getCount() == 0 {
			return 1
		} else {
			return 26
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if termsList.getCount() == 0 {
			return 1
		} else {
			return termsList.getRowCount(section: section)
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if termsList.getCount() == 0 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "noAssignedTermsCell", for: indexPath) as? NoTermsCell
		
			return cell!
			
			
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "assignTermCell", for: indexPath) as? AssignTermCell
			
			let termID = termsList.getTermID(indexPath: indexPath)
			let term = tcTB.getTerm(termID: termID)
						
			cell?.configure(termName: term.name, isSelected: assignedListViewMode == 0 , isEnabled: true)
			
			return cell!
		}
		

	}
	
	/**
	This will generate a NOTIFICATION when a catetory is added or removed from the term
	*/
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let termID = termsList.getTermID(indexPath: indexPath)
		
		if assignedListViewMode == 0 {
			// clicked on this term in the Assigned view. So, will need to REMOVE this category from the term and send out a notification
			
			cc.unassignCategory(termID: termID, categoryID: categoryID)
			
		} else {
			// clicked on this term in the Unassign view. So, will need to ADD this category to the term and send out a notification
			cc.assignCategory(termID: termID, categoryID: categoryID)
		}
			
		// need to update the data model because the term category assign/unassign changed
		updateData()
		
		// need to remove this row from the tableView
		delegate?.shouldRemoveRowAt(indexPath: indexPath)
		
		delegate?.shouldUpdateDisplay()
	
		
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if termsList.getRowCount(section: section) > 0 {
			return termsList.getSectionName(section: section)
		} else {
			return nil
		}
	}
	
}
