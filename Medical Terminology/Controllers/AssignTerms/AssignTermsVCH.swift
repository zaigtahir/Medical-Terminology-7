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
	func shouldReloadRowAt (indexPath: IndexPath)
	func shouldRemoveRowAt (indexPath: IndexPath)
	func shouldClearSearchText()
}


class AssignTermsVCH: NSObject, UITableViewDataSource, UITableViewDelegate

{
	
	var categoryID = 1
	var searchText : String?
	
	/**
	0 = all
	1 = assigned only
	2 = unassigned only
	*/
	var assignedListViewMode = 0
	var termsList = TermsList()
	
	// controllers
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let tu = TextUtilities()
	private let utilities = Utilities()
	
	override init() {
		super.init()
		
		updateData ()
	}
	
	// MARK: - Update data function
	
	/**
	Will update the internal termsList
	*/
	func updateData () {
		
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
		
		let termCell = tableView.dequeueReusableCell(withIdentifier: "termCell", for: indexPath) as? TermCell
		
		let termID = termsList.getTermID(indexPath: indexPath)
		let term = tcTB.getTerm(termID: termID)
		
		termCell!.configure(term: term, indexPath: indexPath)
		
		return termCell!
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// will need to determine the termID then tell the termListVC to perform the seque to the termVC
		
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if termsList.getRowCount(section: section) > 0 {
			return termsList.getSectionName(section: section)
		} else {
			return nil
		}
	}
	
}
