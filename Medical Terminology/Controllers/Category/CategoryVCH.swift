//
//  CategoryVCH2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol CategoryVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
	func duplicateCatetoryName()
}

class CategoryVCH: SingleLineInputDelegate, MultiLineInputDelegate {
	
	// if catetory id = -1, you are adding a new catetory
	
	var category : Category2!
	
	weak var delegate: CategoryVCHDelegate?

	private var referenceSingleLineInputVC : SingleLineInputVC!
	
	private var referenceMultiLineInputVC : MultiLineInputVC!
	
	private let cc = CategoryController2()
	
	init () {
		
	}
		
	func saveCategory() {
		let _ = cc.addCategoryPN (category: category)
	}

	func configureSingleLineInputVC (vc: SingleLineInputVC) {
		
		// setting the class variable
		referenceSingleLineInputVC = vc
		
		vc.textInputVCH.fieldTitle = "CATEGORY NAME"
		vc.textInputVCH.initialText = category.name
		vc.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		vc.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
		vc.textInputVCH.minLength = 1
		vc.textInputVCH.maxLength = myConstants.maxLengthCategoryName
		vc.textInputVCH.propertyReference = .none
		vc.delegate = self

	}
	
	func configureMultiLineInputVC (vc: MultiLineInputVC) {
		
		referenceMultiLineInputVC = vc
		vc.textInputVCH.fieldTitle = "DESCRIPTION"
		vc.textInputVCH.initialText = category.description
		vc.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		vc.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		vc.textInputVCH.minLength = 0
		vc.textInputVCH.maxLength = myConstants.maxLengthCategoryDescription
		vc.textInputVCH.propertyReference = .definition
		vc.delegate = self
		
	}
	// MARK: - delegate functions
	func shouldUpdateSingleLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if category.name == cleanString {
			// nothing changed, just pop off the input vc
			referenceSingleLineInputVC.navigationController?.popViewController(animated: true)
		}
		
		if !cc.categoryNameIsUnique(name: cleanString, notIncludingCategoryID: category.categoryID) {
			// this is a duplicate category name
			delegate?.duplicateCatetoryName()
			return
		}
		
		category.name = cleanString
		
		if category.categoryID != -1 {
			cc.updateCategoryNamePN(categoryID: category.categoryID, newName: cleanString)
		}
		
		delegate?.shouldUpdateDisplay()
		referenceSingleLineInputVC.navigationController?.popViewController(animated: true)
	}
	
	func shouldUpdateMultiLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if category.description == cleanString {
			// nothing changed, just pop off the input vc
			referenceSingleLineInputVC.navigationController?.popViewController(animated: true)
		}
		
		category.description = cleanString
		
		// no notification sent as this is the only VC that will show a category description and it is modal
		
		if category.categoryID != -1 {
			cc.updateCategoryDescription(categoryID: category.categoryID, description: cleanString)
		}
		
		delegate?.shouldUpdateDisplay()
	
		referenceMultiLineInputVC.navigationController?.popViewController(animated: true)
	}
	
	
}


