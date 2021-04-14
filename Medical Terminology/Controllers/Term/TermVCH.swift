//
//  TermVCH2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/11/21.
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

class TermVCH: SingleLineInputDelegate, MultiLineInputDelegate{
	
	/// Everything will be based on this term. If this termID = -1, this will be considered to be a NEW term that is not saved yet
	var term : Term!
	var newTermFavoriteStatus: Bool!
	var currentCategoryID : Int!
	
	var propertyReference : PropertyReference!
	
	var delegate: TermVCHDelegate?
	
	// controllers
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
			
			if term.termID == affectedTermID {
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			
			if term.termID == affectedTermID {
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	// MARK: - move getCategoryNameText ()
	
	func getCategoryNamesText () -> String {
		
		// make list of categories
		var categoryList = ""
		
		for id in term.assignedCategories {
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
		
		if term.name == cleanString {
			// nothing changed
			delegate?.shouldDismissTextInputVC()
			return
		}
		
		if !tc.termNameIsUnique(name: cleanString, notIncludingTermID: term.termID) {
			// this is a duplicate term name!
			delegate?.shouldDisplayDuplicateTermNameAlert()
			return
		}
		
		term.name = cleanString
		
		if term.termID != -1 {
			// update the db
			tc.updateTermNamePN(termID: term.termID, name: cleanString)
		}
		
		delegate?.shouldUpdateDisplay()
		
		delegate?.shouldDismissTextInputVC()
		
	}
	
	// MARK: - MultiLineInputDelegate Function
	
	func shouldUpdateMultiLineInfo (propertyReference: PropertyReference?, cleanString: String) {
		
		switch propertyReference {
		
		case .definition:
			if term.description == cleanString {
				delegate?.shouldDismissTextInputVC()
				return
			}
			
			if term.termID == -1 {
				term.definition = cleanString
			} else {
				tc.updateTermDefinitionPN(termID: term.termID, definition: cleanString)
			}
			
			delegate?.shouldUpdateDisplay()
			delegate?.shouldDismissTextInputVC()
			
		case .example:
			
			if term.example == cleanString {
				delegate?.shouldDismissTextInputVC()
				return
			}
			
			if term.termID == -1 {
				term.example = cleanString
			} else {
				tc.updateTermExamplePN (termID: term.termID, example: cleanString)
			}
			
			delegate?.shouldUpdateDisplay()
			delegate?.shouldDismissTextInputVC()
			
		case .myNotes:
			
			if term.myNotes == cleanString {
				delegate?.shouldDismissTextInputVC()
				return
			}
			
			if term.termID == -1 {
				term.myNotes = cleanString
			} else {
				tc.updateTermMyNotesPN(termID: term.termID, myNotes: cleanString)
				
			}
			
			delegate?.shouldUpdateDisplay()
			delegate?.shouldDismissTextInputVC()
			
		default:
			print ("fatal error passeed a propertyReference that should not be passed here")
		}
	}
}
