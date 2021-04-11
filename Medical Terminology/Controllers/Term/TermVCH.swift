//
//  TermVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol TermVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
	
	/// dismiss single or multiline input vc
	func shouldDismissTextInputVC()
	func shouldDisplayDuplicateTermNameAlert()
}

class TermVCH: SingleLineInputDelegate, MultiLineInputDelegate {

	var termID : Int!
	var currentCategoryID : Int!
	var displayMode = DisplayMode.view
	
	weak var delegate: TermVCHDelegate?
	
	///set this to true when the user is in edit/add mode and the data is valid to save as a term
	var isReadyToSaveTerm = false
	
	// used to store the property type that will be edited with the segue functions
	var propertyReference : PropertyReference?
	
	private let tc = TermController()
	private let cc = CategoryController2()
	
	init () {

		/*
		Notification keys this controller will need to respond to
		This is a modal view controller, and the only thing that will affect it is when the user assigns/unassigns categories and when the term information is edited
		
		assignCategoryKey
		unassignCategoryKey
		
		*/
		
		let nameACK = Notification.Name(myKeys.assignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(assignCategoryN(notification:)), name: nameACK, object: nil)
		
		let nameUCK = Notification.Name(myKeys.unassignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(unassignCategoryN(notification:)), name: nameUCK, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	@objc func assignCategoryN (notification : Notification) {
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			let currentTermID = tc.getTerm(termID: termID).termID
			
			if currentTermID == affectedTermID {
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			let currentTermID = tc.getTerm(termID: termID).termID
			
			if currentTermID == affectedTermID {
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	func getCategoryNamesText () -> String {
		
		// make list of categories
		let categoryIDs = tc.getTermCategoryIDs(termID: termID)
		var categoryList = ""
		
		for id in categoryIDs {
			if (id != myConstants.dbCategoryMyTermsID) && (id != myConstants.dbCategoryAllTermsID) {
				// note not including id 1 = All terms and 2 = My Terms
				
				let category = cc.getCategory(categoryID: id)
				categoryList.append("\(category.name)\n")
			}
		}
		
		return categoryList
	}
	
	// MARK: - SingleLineInputDelegate function
	
	func shouldUpdateSingleLineInfo (propertyReference: PropertyReference, cleanString: String) {
		
		// this will only be for the term name
		
		let term = tc.getTerm(termID: termID)
		
		if term.name == cleanString {
			// nothing changed
			// home VC can dismiss the input VC
			delegate?.shouldDismissTextInputVC()
			return
		}
		
		if !tc.termNameIsUnique(name: cleanString, notIncludingTermID: term.termID) {
			// this is a duplicate term name!
			delegate?.shouldDisplayDuplicateTermNameAlert()
			return
		}
		
		// update the db
		tc.updateTermNamePN(termID: termID, name: cleanString)
		
		delegate?.shouldUpdateDisplay()
		
		delegate?.shouldDismissTextInputVC()
		
	}
	
	// MARK: - MultiLineInputDelegate Function
	
	func shouldUpdateMultiLineInfo(inputVC: MultiLineInputVC, propertyReference: PropertyReference?, cleanString: String) {
		
		print("getting update message in term vch")
		
		let term = tc.getTerm(termID: termID)
		
		switch propertyReference {
		
		case .definition:
			
			if term.definition != cleanString {
				tc.updateTermDefinitionPN(termID: term.termID, definition: cleanString)
			}
			
			delegate?.shouldDismissTextInputVC()
			
		case .example:
			
			if term.example != cleanString {
				tc.updateTermExamplePN(termID: termID, example: cleanString)
			}
			
			delegate?.shouldDismissTextInputVC()
			
		case .myNotes:
			
			if term.myNotes != cleanString {
				tc.updateTermMyNotesPN(termID: termID, myNotes: cleanString)
			}
			
			delegate?.shouldDismissTextInputVC()
			
		default:
			print ("fatal error no matching case found in shouldUpdateMultilineInfo")
		
		}
	}
	
	
}
