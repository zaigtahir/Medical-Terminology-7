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
	func shouldShowDuplicateTermNameAlert()
}

class TermVCH: SingleLineInputDelegate, MultiLineInputDelegate, TermCategoryIDsDelegate {
	
	/// Everything will be based on this term. If this termID = -1, this will be considered to be a NEW term that is not saved yet
	// MARK: to delete later
	var term : TermTB!
	var currentCategoryID : Int!
	// to delete
	
	var propertyReference : PropertyReference!
	var delegate: TermVCHDelegate?
	
	// Updated variables
	private var initialTerm: TermTB!
	var editedTerm = TermTB ()
	
	
	// controllers
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let sc = SettingsController()
	private let utilities = Utilities()
	
	private var singleLineInputVC : SingleLineInputVC!
	private var multiLineInputVC : MultiLineInputVC!
	
	init () {
		
	}
	
	/**
	The assignedCategories must be initialized before calling
	*/
	func setInitialTerm (initialTerm: TermTB) {
		// copy over the relevant values
		self .initialTerm = initialTerm
		
		editedTerm.termID = initialTerm.termID
		editedTerm.name = initialTerm.name
		editedTerm.definition = initialTerm.definition
		editedTerm.example = initialTerm.example
		editedTerm.audioFile = initialTerm.audioFile
		editedTerm.isStandard = initialTerm.isStandard
		editedTerm.secondCategoryID = initialTerm.secondCategoryID
		editedTerm.thirdCategoryID = initialTerm.thirdCategoryID
		
		editedTerm.assignedCategories = initialTerm.assignedCategories
	
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	func termWasEdited () -> Bool {
		// return true if there are any changes
		
		if editedTerm.termID != initialTerm.termID {return true}
		if editedTerm.name != initialTerm.name {return true}
		if editedTerm.definition != initialTerm.definition {return true}
		if editedTerm.example != initialTerm.example {return true}
		if editedTerm.myNotes != initialTerm.myNotes {return true}
		if editedTerm.audioFile != initialTerm.audioFile {return true}
		if !utilities.containSameElements(array1: initialTerm.assignedCategories, array2: editedTerm.assignedCategories)  {return true}
		
		return false
	}
	
	func getCategoryNamesText () -> String {
		
		// make list of categories
		var categoryList = ""
		
		for id in editedTerm.assignedCategories {
			let category = cc.getCategory(categoryID: id)
			categoryList.append("\(category.name)\n")
		}
		
		return categoryList
	}
	
	
	// MARK: - SingleLineInputDelegate function
	
	func shouldUpdateSingleLineInfo (propertyReference: PropertyReference?, cleanString: String) {
		
		if editedTerm.name == cleanString {
			// nothing changed
			singleLineInputVC.navigationController?.popViewController(animated: true)
			return
		}
		
		if !tcTB.termNameIsUnique(name: cleanString, notIncludingTermID: editedTerm.termID) {
			// this is a duplicate term name!
			delegate?.shouldShowDuplicateTermNameAlert()
			return
		}
		
		editedTerm.name = cleanString
		
		delegate?.shouldUpdateDisplay()
		singleLineInputVC.navigationController?.popViewController(animated: true)
		
	}
	
	// MARK: - MultiLineInputDelegate Function
	
	func shouldUpdateMultiLineInfo (propertyReference: PropertyReference?, cleanString: String) {
		
		switch propertyReference {
		
		case .definition:
			
			editedTerm.definition = cleanString
			
		case .example:
			
			editedTerm.example = cleanString
			
		case .myNotes:
			
			editedTerm.myNotes = cleanString
			
		default:
			print ("fatal error passeed a propertyReference that should not be passed here")
		}
		
		
		delegate?.shouldUpdateDisplay()
		multiLineInputVC.navigationController?.popViewController(animated: true)
		
	}
	
		
	func saveNewTerm () {
		
		// saves new term and loads it as the initial term
		let addedTermID = tcTB.saveNewTermPN(term: editedTerm)
		
		let newTerm  = tcTB.getTerm(termID: addedTermID)
		
		setInitialTerm(initialTerm: newTerm)
	
	}
	
	func updateTerm () {
		
		// will update the db with values from the edited term, and set the edited term as the initial term so that when the display refreshes, the VC will show the saved state
		
		//reset the editedTerm as the initialTerm
		setInitialTerm(initialTerm: editedTerm)
		
		tcTB.updateTermPN(term: editedTerm)
	
		delegate?.shouldUpdateDisplay()
	
	}
	
	// MARK: - termCategoryIDsChangedDelegate
	
	func termCategoryIDsChanged(categoryIDs: [Int]) {
		editedTerm.assignedCategories = categoryIDs
		delegate?.shouldUpdateDisplay()
	}
	
	// MARK: - Moved segues
	
	func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueAssignCategory:
			prepareAssignCategorySegue(for: segue)
			
		case myConstants.segueSingleLineInput:
			
			prepareEditNameSegue(for: segue)
			
		case myConstants.segueMultiLineInput:
			
			switch propertyReference  {
			
			case .definition:
				
				prepareEditDefinitionSegue(for: segue)
				
			case .example:
				
				prepareEditExampleSegue(for: segue)
				
			case .myNotes:
				
				prepareEditMyNotesSegue(for: segue)
				
			default:
				print("fatal error, no segue identifier found in prepare TermVC")
			}
			
		default:
			print("fatal error, no segue identifier found in prepare TermVC")
		}
	}
	
	private func prepareAssignCategorySegue (for segue: UIStoryboardSegue) {
		
		let nc = segue.destination as! UINavigationController
		let vc = nc.topViewController as! CategoryListVC
		vc.categoryListVCH.assignedCategoryIDsDelegate = self
		
		vc.categoryListVCH.setupAssignCategoryMode(term: editedTerm)
		
		
	}
	
	private func prepareEditNameSegue (for segue: UIStoryboardSegue) {
		singleLineInputVC = segue.destination as? SingleLineInputVC
		singleLineInputVC.textInputVCH.fieldTitle = "TERM NAME"
		singleLineInputVC.textInputVCH.initialText = editedTerm.name
		singleLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		singleLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
		singleLineInputVC.textInputVCH.minLength = 1
		singleLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermName
		singleLineInputVC.textInputVCH.propertyReference = .name
		
		singleLineInputVC.delegate = self
	}
	
	private func prepareEditDefinitionSegue (for segue: UIStoryboardSegue) {
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "DEFINITION"
		multiLineInputVC.textInputVCH.initialText = editedTerm.definition
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermDefinition
		multiLineInputVC.textInputVCH.propertyReference = .definition
		multiLineInputVC.delegate = self
	}
	
	private func prepareEditExampleSegue (for segue: UIStoryboardSegue) {
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "EXAMPLE"
		multiLineInputVC.textInputVCH.initialText = editedTerm.example
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermExample
		multiLineInputVC.textInputVCH.propertyReference = .example
		multiLineInputVC.delegate = self
	}
	
	private func prepareEditMyNotesSegue (for segue: UIStoryboardSegue) {
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "MY NOTES"
		multiLineInputVC.textInputVCH.initialText = editedTerm.myNotes
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ? ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/?.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthMyNotes
		multiLineInputVC.textInputVCH.propertyReference = .myNotes
		multiLineInputVC.delegate = self
	}
	
}
