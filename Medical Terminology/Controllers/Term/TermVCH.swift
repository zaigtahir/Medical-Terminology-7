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
	func duplicateTermName()
}

class TermVCH: SingleLineInputDelegate, MultiLineInputDelegate{
	
	/// Everything will be based on this term. If this termID = -1, this will be considered to be a NEW term that is not saved yet
	var term : TermTB!
	var currentCategoryID : Int!
	var propertyReference : PropertyReference!
	var delegate: TermVCHDelegate?
	
	// controllers
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let sc = SettingsController()
	
	private var singleLineInputVC : SingleLineInputVC!
	private var multiLineInputVC : MultiLineInputVC!
	
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
	
	func updateData (){
		
		// If the termID = -1, I will be updating the term object locally so there is no updating needed
		if term.termID != -1 {
			term = tcTB.getTerm(termID: term.termID)
			term.assignedCategories = tcTB.getTermCategoryIDs(termID: term.termID)
			term.isFavorite = tcTB.getFavoriteStatus(termID: term.termID)
		}
	}
	
	func saveTerm () {
		let newTermID = tcTB.saveNewTerm(term: term)
		if sc.isDevelopmentMode() {
			print("TermVCH: saveTerm, new termID = \(newTermID)")
		}
	}
	
	// MARK: - notification functions
	@objc func assignCategoryN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			
			if term.termID == affectedTermID {
				
				// if this is a new term, need to
				
				updateData()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			
			updateData()
			
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
			let category = cc.getCategory(categoryID: id)
			categoryList.append("\(category.name)\n")
		}
		
		return categoryList
	}
	
	// MARK: - SingleLineInputDelegate function
	
	func shouldUpdateSingleLineInfo (propertyReference: PropertyReference?, cleanString: String) {
		
		if term.name == cleanString {
			// nothing changed
			singleLineInputVC.navigationController?.popViewController(animated: true)
			return
		}
		
		if !tcTB.termNameIsUnique(name: cleanString, notIncludingTermID: term.termID) {
			// this is a duplicate term name!
			delegate?.duplicateTermName()
			return
		}
		
		term.name = cleanString
		
		if term.termID != -1 {
			// update the db
			tcTB.updateTermNamePN(termID: term.termID, name: cleanString)
		}
		
		updateData()
		delegate?.shouldUpdateDisplay()
		singleLineInputVC.navigationController?.popViewController(animated: true)
		
	}
	
	// MARK: - MultiLineInputDelegate Function
	
	func shouldUpdateMultiLineInfo (propertyReference: PropertyReference?, cleanString: String) {
		
		switch propertyReference {
		
		case .definition:
			if term.description == cleanString {
				multiLineInputVC.navigationController?.popViewController(animated: true)
				return
			}
			
			if term.termID == -1 {
				term.definition = cleanString
			} else {
				tcTB.updateTermDefinitionPN(termID: term.termID, definition: cleanString)
			}
			
		case .example:
			
			if term.example == cleanString {
				multiLineInputVC.navigationController?.popViewController(animated: true)
				return
			}
			
			if term.termID == -1 {
				term.example = cleanString
			} else {
				tcTB.updateTermExamplePN (termID: term.termID, example: cleanString)
			}
			
			
		case .myNotes:
			
			if term.myNotes == cleanString {
				multiLineInputVC.navigationController?.popViewController(animated: true)
				return
			}
			
			if term.termID == -1 {
				term.myNotes = cleanString
			} else {
				tcTB.updateTermMyNotesPN(termID: term.termID, myNotes: cleanString)
				
			}
			
		default:
			print ("fatal error passeed a propertyReference that should not be passed here")
		}
		
		
		if term.termID != -1 {
			updateData()
		}
		
		delegate?.shouldUpdateDisplay()
		multiLineInputVC.navigationController?.popViewController(animated: true)
		
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
		
		vc.categoryListVCH.setupAssignCategoryMode(term: term)
		
	}
	
	private func prepareEditNameSegue (for segue: UIStoryboardSegue) {
		singleLineInputVC = segue.destination as? SingleLineInputVC
		singleLineInputVC.textInputVCH.fieldTitle = "TERM NAME"
		singleLineInputVC.textInputVCH.initialText = term.name
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
		multiLineInputVC.textInputVCH.initialText = term.definition
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
		multiLineInputVC.textInputVCH.initialText = term.example
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
		multiLineInputVC.textInputVCH.initialText = term.myNotes
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ? ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/?.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthMyNotes
		multiLineInputVC.textInputVCH.propertyReference = .myNotes
		multiLineInputVC.delegate = self
	}
	
}
