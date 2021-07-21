//
//  AssignTermsVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/4/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol AssignTermsVCHDelegate: AnyObject {
	
	func shouldReloadTable()
	func shouldUpdateDisplay()
	func shouldRemoveRowAt (indexPath: IndexPath)
	func shouldClearSearchText()
	func shouldShowAlert(title: String, message: String)
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
						
			cell?.configure(term: term, categoryID: categoryID, isSelected: assignedListViewMode == 0)
			
			return cell!
		}
	
	}
	
	/**
	This will generate a   termCategoryIDsChangedKey NOTIFICATION when a catetory is added or removed from the term
	*/
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		
		// can i get the cell
		let cell = tableView.cellForRow(at: indexPath) as! AssignTermCell
		cell.toggleSelectImage()
		
		let termID = termsList.getTermID(indexPath: indexPath)
		
		let selectedTerm = tcTB.getTerm(termID: termID)
		
		let originalCategoryIDs = tcTB.getTermCategoryIDs(termID: termID)
		
		// evaluate locked categories
		/*
		category1
		assigned row: All terms are automatically assigned to this category and may not be removed.
		unassigned row, no terms will ever show up here

		category 2
		assigned row: Terms you make are automatically assigned to this category and may not be removed.
		unassigned row: Only terms you make can be assigned to this category. This this is a predefined term and can not be assigned to “My Terms”

		any other category:
		if user clicks on predefined category (will always be in assigned row)
		This is a predefined category for this term and may not be removed.
		*/
		
		
		if categoryID == 1 {
			delegate?.shouldShowAlert(title: "Preassigned Term", message: "All terms are automatically assigned to this category and may not be removed")
			return
		}
		
		if categoryID == 2 {
			
			if assignedListViewMode == 0 {
				// looknig at assigned terms
				delegate?.shouldShowAlert(title: "Preassigned Term", message: "All terms you creatre are automatically assigned to the the My Terms category, and may not be removed from this category")
			} else {
				delegate?.shouldShowAlert(title: "Preassigned Term", message: "You can not add this term to the My Terms category. Any terms you create will automatically be added to the My Terms category.")
			}

			return
		}
		
		if ( categoryID == selectedTerm.secondCategoryID || categoryID == selectedTerm.thirdCategoryID ) {
			
			delegate?.shouldShowAlert(title: "Preassigned Category", message: "This term is preassigned to this category and may not be removed.")
			
			return
		}
		
		// now evaluate all other categories
		
		
		if assignedListViewMode == 0 {
			// clicked on this term in the Assigned view. So, will need to REMOVE this category from the term and send out a notification
			
			cc.unassignCategory(termID: termID, categoryID: categoryID)
			
		} else {
			// clicked on this term in the Unassign view. So, will need to ADD this category to the term and send out a notification
			cc.assignCategory(termID: termID, categoryID: categoryID)
		}
		
		// need to setup to send out a notification of the category change
		
			
		// need to update the data model because the term category assign/unassign changed
		updateData()
		
		let nName = Notification.Name(myKeys.termCategoryIDsChangedKey)
		
		NotificationCenter.default.post(name: nName, object: self, userInfo: ["termID": [termID], "originalCategoryIDs" : originalCategoryIDs])
		
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
